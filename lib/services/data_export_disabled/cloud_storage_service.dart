import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import 'data_export_models.dart';

/// Cloud storage integration service for sharing and syncing export files
class CloudStorageService {
  final GoogleSignIn _googleSignIn;
  drive.DriveApi? _driveApi;
  
  CloudStorageService()
      : _googleSignIn = GoogleSignIn(
          scopes: [
            'https://www.googleapis.com/auth/drive.file',
            'https://www.googleapis.com/auth/drive.readonly',
          ],
        );
  
  /// Upload file to Google Drive
  Future<ExportResult> uploadToGoogleDrive({
    required String filePath,
    String? folderId,
    String? fileName,
    bool makePublic = false,
    ShareConfig? shareConfig,
  }) async {
    try {
      await _ensureGoogleDriveAuthenticated();
      
      final file = File(filePath);
      if (!await file.exists()) {
        return const ExportResult(
          success: false,
          message: 'File not found',
          filePath: null,
          fileSize: 0,
        );
      }
      
      final displayName = fileName ?? path.basename(filePath);
      final mimeType = _getMimeType(filePath);
      
      // Create file metadata
      final driveFile = drive.File()
        ..name = displayName
        ..parents = folderId != null ? [folderId] : null;
      
      // Create media
      final media = drive.Media(file.openRead(), await file.length());
      
      // Upload file
      final uploadedFile = await _driveApi!.files.create(
        driveFile,
        uploadMedia: media,
        uploadOptions: drive.ResumableUploadOptions(),
      );
      
      // Make public if requested
      String? publicUrl;
      if (makePublic) {
        await _driveApi!.permissions.create(
          drive.Permission()
            ..role = 'reader'
            ..type = 'anyone',
          uploadedFile.id!,
        );
        publicUrl = 'https://drive.google.com/file/d/${uploadedFile.id}/view';
      }
      
      // Handle sharing if configured
      if (shareConfig != null) {
        await _shareGoogleDriveFile(uploadedFile.id!, shareConfig);
      }
      
      return ExportResult(
        success: true,
        message: 'File uploaded to Google Drive successfully',
        filePath: publicUrl ?? 'https://drive.google.com/file/d/${uploadedFile.id}',
        fileSize: await file.length(),
        exportedAt: DateTime.now(),
        metadata: {
          'provider': 'googleDrive',
          'fileId': uploadedFile.id,
          'fileName': displayName,
          'mimeType': mimeType,
          'publicUrl': publicUrl,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Google Drive upload error: $e');
      }
      return ExportResult(
        success: false,
        message: 'Google Drive upload failed: ${e.toString()}',
        filePath: null,
        fileSize: 0,
      );
    }
  }
  
  /// Upload file to Dropbox
  Future<ExportResult> uploadToDropbox({
    required String filePath,
    required String accessToken,
    String? folderPath,
    String? fileName,
    ShareConfig? shareConfig,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return const ExportResult(
          success: false,
          message: 'File not found',
          filePath: null,
          fileSize: 0,
        );
      }
      
      final displayName = fileName ?? path.basename(filePath);
      final dropboxPath = '${folderPath ?? ''}/$displayName';
      
      // Upload file
      final client = http.Client();
      final fileBytes = await file.readAsBytes();
      
      final response = await client.post(
        Uri.parse('https://content.dropboxapi.com/2/files/upload'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Dropbox-API-Arg': jsonEncode({
            'path': dropboxPath,
            'mode': 'add',
            'autorename': true,
          }),
          'Content-Type': 'application/octet-stream',
        },
        body: fileBytes,
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Create sharing link if requested
        String? sharingUrl;
        if (shareConfig != null) {
          sharingUrl = await _createDropboxSharingLink(accessToken, dropboxPath);
        }
        
        return ExportResult(
          success: true,
          message: 'File uploaded to Dropbox successfully',
          filePath: sharingUrl ?? dropboxPath,
          fileSize: await file.length(),
          exportedAt: DateTime.now(),
          metadata: {
            'provider': 'dropbox',
            'path': responseData['path_display'],
            'fileName': displayName,
            'sharingUrl': sharingUrl,
          },
        );
      } else {
        throw Exception('Dropbox upload failed: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Dropbox upload error: $e');
      }
      return ExportResult(
        success: false,
        message: 'Dropbox upload failed: ${e.toString()}',
        filePath: null,
        fileSize: 0,
      );
    }
  }
  
  /// Upload file to OneDrive
  Future<ExportResult> uploadToOneDrive({
    required String filePath,
    required String accessToken,
    String? folderId,
    String? fileName,
    ShareConfig? shareConfig,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return const ExportResult(
          success: false,
          message: 'File not found',
          filePath: null,
          fileSize: 0,
        );
      }
      
      final displayName = fileName ?? path.basename(filePath);
      final fileBytes = await file.readAsBytes();
      
      // Determine upload endpoint
      final uploadPath = folderId != null 
          ? '/me/drive/items/$folderId:/$displayName:/content'
          : '/me/drive/root:/$displayName:/content';
      
      final client = http.Client();
      final response = await client.put(
        Uri.parse('https://graph.microsoft.com/v1.0$uploadPath'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/octet-stream',
        },
        body: fileBytes,
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Create sharing link if requested
        String? sharingUrl;
        if (shareConfig != null) {
          sharingUrl = await _createOneDriveSharingLink(accessToken, responseData['id']);
        }
        
        return ExportResult(
          success: true,
          message: 'File uploaded to OneDrive successfully',
          filePath: sharingUrl ?? responseData['webUrl'],
          fileSize: await file.length(),
          exportedAt: DateTime.now(),
          metadata: {
            'provider': 'oneDrive',
            'fileId': responseData['id'],
            'fileName': displayName,
            'webUrl': responseData['webUrl'],
            'sharingUrl': sharingUrl,
          },
        );
      } else {
        throw Exception('OneDrive upload failed: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('OneDrive upload error: $e');
      }
      return ExportResult(
        success: false,
        message: 'OneDrive upload failed: ${e.toString()}',
        filePath: null,
        fileSize: 0,
      );
    }
  }
  
  /// Create a shared folder for project collaboration
  Future<Map<String, dynamic>> createCollaborationFolder({
    required String provider,
    required String folderName,
    required String accessToken,
    List<String>? collaboratorEmails,
  }) async {
    switch (provider.toLowerCase()) {
      case 'googledrive':
        return await _createGoogleDriveFolder(folderName, collaboratorEmails);
      case 'dropbox':
        return await _createDropboxFolder(accessToken, folderName, collaboratorEmails);
      case 'onedrive':
        return await _createOneDriveFolder(accessToken, folderName, collaboratorEmails);
      default:
        throw Exception('Unsupported cloud storage provider: $provider');
    }
  }
  
  /// Sync local export directory with cloud storage
  Future<List<ExportResult>> syncWithCloud({
    required String provider,
    required String accessToken,
    required String localDirectory,
    String? cloudFolderId,
  }) async {
    final results = <ExportResult>[];
    final directory = Directory(localDirectory);
    
    if (!await directory.exists()) {
      return results;
    }
    
    await for (final entity in directory.list()) {
      if (entity is File) {
        ExportResult result;
        
        switch (provider.toLowerCase()) {
          case 'googledrive':
            result = await uploadToGoogleDrive(
              filePath: entity.path,
              folderId: cloudFolderId,
            );
            break;
          case 'dropbox':
            result = await uploadToDropbox(
              filePath: entity.path,
              accessToken: accessToken,
            );
            break;
          case 'onedrive':
            result = await uploadToOneDrive(
              filePath: entity.path,
              accessToken: accessToken,
              folderId: cloudFolderId,
            );
            break;
          default:
            result = ExportResult(
              success: false,
              message: 'Unsupported provider: $provider',
              filePath: null,
              fileSize: 0,
            );
        }
        
        results.add(result);
      }
    }
    
    return results;
  }
  
  /// Get cloud storage usage and quota information
  Future<Map<String, dynamic>> getStorageInfo({
    required String provider,
    required String accessToken,
  }) async {
    switch (provider.toLowerCase()) {
      case 'googledrive':
        return await _getGoogleDriveStorageInfo();
      case 'dropbox':
        return await _getDropboxStorageInfo(accessToken);
      case 'onedrive':
        return await _getOneDriveStorageInfo(accessToken);
      default:
        throw Exception('Unsupported cloud storage provider: $provider');
    }
  }
  
  // Private helper methods
  
  Future<void> _ensureGoogleDriveAuthenticated() async {
    final account = await _googleSignIn.signInSilently();
    if (account == null) {
      throw Exception('Google Drive authentication required');
    }
    
    final authHeaders = await account.authHeaders;
    final credentials = auth.AccessCredentials(
      auth.AccessToken(
        'Bearer',
        authHeaders['Authorization']!.substring('Bearer '.length),
        DateTime.now().add(const Duration(hours: 1)),
      ),
      null,
      _googleSignIn.scopes,
    );
    
    final client = auth.authenticatedClient(http.Client(), credentials);
    _driveApi = drive.DriveApi(client);
  }
  
  Future<void> _shareGoogleDriveFile(String fileId, ShareConfig shareConfig) async {
    for (final email in shareConfig.recipients) {
      await _driveApi!.permissions.create(
        drive.Permission()
          ..role = 'reader'
          ..type = 'user'
          ..emailAddress = email,
        fileId,
        sendNotificationEmail: true,
      );
    }
  }
  
  Future<String?> _createDropboxSharingLink(String accessToken, String filePath) async {
    final client = http.Client();
    final response = await client.post(
      Uri.parse('https://api.dropboxapi.com/2/sharing/create_shared_link_with_settings'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'path': filePath,
        'settings': {
          'requested_visibility': 'public',
        },
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['url'];
    }
    
    return null;
  }
  
  Future<String?> _createOneDriveSharingLink(String accessToken, String fileId) async {
    final client = http.Client();
    final response = await client.post(
      Uri.parse('https://graph.microsoft.com/v1.0/me/drive/items/$fileId/createLink'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'type': 'view',
        'scope': 'anonymous',
      }),
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['link']['webUrl'];
    }
    
    return null;
  }
  
  Future<Map<String, dynamic>> _createGoogleDriveFolder(
    String folderName,
    List<String>? collaboratorEmails,
  ) async {
    await _ensureGoogleDriveAuthenticated();
    
    final folder = drive.File()
      ..name = folderName
      ..mimeType = 'application/vnd.google-apps.folder';
    
    final createdFolder = await _driveApi!.files.create(folder);
    
    // Add collaborators
    if (collaboratorEmails != null) {
      for (final email in collaboratorEmails) {
        await _driveApi!.permissions.create(
          drive.Permission()
            ..role = 'writer'
            ..type = 'user'
            ..emailAddress = email,
          createdFolder.id!,
        );
      }
    }
    
    return {
      'id': createdFolder.id,
      'name': createdFolder.name,
      'webViewLink': 'https://drive.google.com/drive/folders/${createdFolder.id}',
    };
  }
  
  Future<Map<String, dynamic>> _createDropboxFolder(
    String accessToken,
    String folderName,
    List<String>? collaboratorEmails,
  ) async {
    final client = http.Client();
    
    // Create folder
    final response = await client.post(
      Uri.parse('https://api.dropboxapi.com/2/files/create_folder_v2'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'path': '/$folderName',
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'path': data['metadata']['path_display'],
        'name': data['metadata']['name'],
      };
    }
    
    throw Exception('Failed to create Dropbox folder');
  }
  
  Future<Map<String, dynamic>> _createOneDriveFolder(
    String accessToken,
    String folderName,
    List<String>? collaboratorEmails,
  ) async {
    final client = http.Client();
    
    final response = await client.post(
      Uri.parse('https://graph.microsoft.com/v1.0/me/drive/root/children'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': folderName,
        'folder': {},
        '@microsoft.graph.conflictBehavior': 'rename',
      }),
    );
    
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return {
        'id': data['id'],
        'name': data['name'],
        'webUrl': data['webUrl'],
      };
    }
    
    throw Exception('Failed to create OneDrive folder');
  }
  
  Future<Map<String, dynamic>> _getGoogleDriveStorageInfo() async {
    await _ensureGoogleDriveAuthenticated();
    
    final about = await _driveApi!.about.get($fields: 'storageQuota');
    final quota = about.storageQuota!;
    
    return {
      'provider': 'googleDrive',
      'totalBytes': int.parse(quota.limit ?? '0'),
      'usedBytes': int.parse(quota.usage ?? '0'),
      'availableBytes': int.parse(quota.limit ?? '0') - int.parse(quota.usage ?? '0'),
    };
  }
  
  Future<Map<String, dynamic>> _getDropboxStorageInfo(String accessToken) async {
    final client = http.Client();
    
    final response = await client.post(
      Uri.parse('https://api.dropboxapi.com/2/users/get_space_usage'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final used = data['used'] as int;
      final allocated = data['allocation']['allocated'] as int;
      
      return {
        'provider': 'dropbox',
        'totalBytes': allocated,
        'usedBytes': used,
        'availableBytes': allocated - used,
      };
    }
    
    throw Exception('Failed to get Dropbox storage info');
  }
  
  Future<Map<String, dynamic>> _getOneDriveStorageInfo(String accessToken) async {
    final client = http.Client();
    
    final response = await client.get(
      Uri.parse('https://graph.microsoft.com/v1.0/me/drive'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final quota = data['quota'];
      final total = quota['total'] as int;
      final used = quota['used'] as int;
      
      return {
        'provider': 'oneDrive',
        'totalBytes': total,
        'usedBytes': used,
        'availableBytes': total - used,
      };
    }
    
    throw Exception('Failed to get OneDrive storage info');
  }
  
  String _getMimeType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    switch (extension) {
      case '.pdf':
        return 'application/pdf';
      case '.xlsx':
      case '.xls':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case '.csv':
        return 'text/csv';
      case '.json':
        return 'application/json';
      case '.xml':
        return 'application/xml';
      case '.zip':
        return 'application/zip';
      default:
        return 'application/octet-stream';
    }
  }
}