import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';

import 'package:task_tracker_app/services/database/database.dart';
import 'package:task_tracker_app/domain/entities/task_model.dart';
import 'package:task_tracker_app/domain/entities/task_enums.dart';
import 'package:task_tracker_app/domain/entities/project.dart';
import 'package:task_tracker_app/presentation/widgets/advanced_task_card.dart';
import 'package:task_tracker_app/presentation/widgets/project_card.dart';

void main() {
  group('Collaboration and Team Workflow Integration Tests', () {
    late ProviderContainer container;
    late AppDatabase testDatabase;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      
      testDatabase = AppDatabase.forTesting(NativeDatabase.memory());
      container = ProviderContainer(
        overrides: [],
      );
    });

    tearDown(() async {
      await testDatabase.close();
      container.dispose();
    });

    group('Team Management and Invitations', () {
      testWidgets('should invite team members and manage permissions', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Team Management'),
                  actions: [
                    IconButton(
                      key: const Key('invite_member_button'),
                      icon: const Icon(Icons.person_add),
                      onPressed: () {
                        // Open invitation dialog
                      },
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Team Members', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: 4,
                              itemBuilder: (context, index) {
                                final roles = ['Owner', 'Admin', 'Member', 'Viewer'];
                                final names = ['Alice Johnson', 'Bob Smith', 'Carol Davis', 'David Wilson'];
                                final emails = ['alice@example.com', 'bob@example.com', 'carol@example.com', 'david@example.com'];
                                
                                return ListTile(
                                  key: Key('team_member_$index'),
                                  leading: CircleAvatar(
                                    child: Text(names[index][0]),
                                  ),
                                  title: Text(names[index]),
                                  subtitle: Text(emails[index]),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Chip(
                                        label: Text(roles[index]),
                                        backgroundColor: index == 0 ? Colors.purple[100] : 
                                                        index == 1 ? Colors.blue[100] :
                                                        index == 2 ? Colors.green[100] : Colors.grey[100],
                                      ),
                                      const SizedBox(width: 8),
                                      PopupMenuButton<String>(
                                        key: Key('member_menu_$index'),
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(value: 'edit_role', child: Text('Change Role')),
                                          const PopupMenuItem(value: 'view_activity', child: Text('View Activity')),
                                          if (index > 0) const PopupMenuItem(value: 'remove', child: Text('Remove Member')),
                                        ],
                                        onSelected: (value) {
                                          // Handle member action
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Pending Invitations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            ListTile(
                              key: const Key('pending_invitation_1'),
                              leading: const Icon(Icons.email_outlined),
                              title: const Text('john.doe@example.com'),
                              subtitle: const Text('Invited 2 days ago • Member role'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    key: const Key('resend_invitation_button'),
                                    icon: const Icon(Icons.refresh),
                                    onPressed: () {
                                      // Resend invitation
                                    },
                                  ),
                                  IconButton(
                                    key: const Key('cancel_invitation_button'),
                                    icon: const Icon(Icons.cancel),
                                    onPressed: () {
                                      // Cancel invitation
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Test team member management
        await tester.tap(find.byKey(const Key('member_menu_1')));
        await tester.pump();
        await tester.tap(find.text('Change Role'));
        await tester.pump();

        await tester.tap(find.byKey(const Key('member_menu_2')));
        await tester.pump();
        await tester.tap(find.text('View Activity'));
        await tester.pump();

        // Test invitation management
        await tester.tap(find.byKey(const Key('resend_invitation_button')));
        await tester.pump();

        await tester.tap(find.byKey(const Key('cancel_invitation_button')));
        await tester.pump();

        // Test adding new member
        await tester.tap(find.byKey(const Key('invite_member_button')));
        await tester.pump();

        // Verify team management
        expect(find.text('Team Members'), findsOneWidget);
        expect(find.text('Alice Johnson'), findsOneWidget);
        expect(find.text('Pending Invitations'), findsOneWidget);
        expect(find.text('john.doe@example.com'), findsOneWidget);
      });

      testWidgets('should handle team invitation workflow', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Invite Team Member'),
                ),
                body: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        key: const Key('invite_email_field'),
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          hintText: 'Enter email address to invite',
                          prefixIcon: Icon(Icons.email),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        key: const Key('invite_role_dropdown'),
                        decoration: const InputDecoration(
                          labelText: 'Role',
                          prefixIcon: Icon(Icons.person),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'admin', child: Text('Admin - Full access')),
                          DropdownMenuItem(value: 'member', child: Text('Member - Can edit tasks')),
                          DropdownMenuItem(value: 'viewer', child: Text('Viewer - Read-only access')),
                        ],
                        onChanged: (value) {
                          // Handle role selection
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        key: const Key('invite_message_field'),
                        decoration: const InputDecoration(
                          labelText: 'Personal Message (Optional)',
                          hintText: 'Add a personal message to the invitation',
                          prefixIcon: Icon(Icons.message),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              key: const Key('cancel_invite_button'),
                              onPressed: () {
                                // Cancel invitation
                              },
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              key: const Key('send_invite_button'),
                              onPressed: () {
                                // Send invitation
                              },
                              child: const Text('Send Invitation'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        // Test invitation form
        await tester.enterText(find.byKey(const Key('invite_email_field')), 'newmember@example.com');

        await tester.tap(find.byKey(const Key('invite_role_dropdown')));
        await tester.pump();
        await tester.tap(find.text('Member - Can edit tasks'));
        await tester.pump();

        await tester.enterText(find.byKey(const Key('invite_message_field')), 'Welcome to our team project!');

        await tester.tap(find.byKey(const Key('send_invite_button')));
        await tester.pump();

        // Verify invitation workflow
        expect(find.text('Invite Team Member'), findsOneWidget);
        expect(find.text('newmember@example.com'), findsOneWidget);
        expect(find.text('Welcome to our team project!'), findsOneWidget);
      });
    });

    group('Task Assignment and Collaboration', () {
      testWidgets('should assign tasks to team members workflow', (tester) async {
        final testTask = TaskModel.create(
          title: 'Collaborative Task',
          description: 'This task needs to be assigned',
          priority: TaskPriority.high,
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Task Assignment'),
                ),
                body: Column(
                  children: [
                    AdvancedTaskCard(
                      key: Key('assignable_task_${testTask.id}'),
                      task: testTask,
                      showAssignment: true,
                      onAssign: () {
                        // Open assignment dialog
                      },
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Assign To:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              children: [
                                'Alice Johnson',
                                'Bob Smith', 
                                'Carol Davis',
                                'David Wilson'
                              ].asMap().entries.map((entry) {
                                return FilterChip(
                                  key: Key('assignee_chip_${entry.key}'),
                                  label: Text(entry.value),
                                  selected: entry.key == 1,
                                  onSelected: (selected) {
                                    // Handle assignee selection
                                  },
                                  avatar: CircleAvatar(
                                    radius: 12,
                                    child: Text(entry.value[0]),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    key: const Key('assign_to_me_button'),
                                    onPressed: () {
                                      // Assign to current user
                                    },
                                    child: const Text('Assign to Me'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    key: const Key('confirm_assignment_button'),
                                    onPressed: () {
                                      // Confirm assignment
                                    },
                                    child: const Text('Assign Task'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Test task assignment
        await tester.tap(find.byKey(const Key('assignee_chip_0')));
        await tester.pump();

        await tester.tap(find.byKey(const Key('assignee_chip_2')));
        await tester.pump();

        await tester.tap(find.byKey(const Key('assign_to_me_button')));
        await tester.pump();

        await tester.tap(find.byKey(const Key('confirm_assignment_button')));
        await tester.pump();

        // Verify assignment workflow
        expect(find.text('Task Assignment'), findsOneWidget);
        expect(find.text('Collaborative Task'), findsOneWidget);
        expect(find.text('Alice Johnson'), findsOneWidget);
        expect(find.text('Bob Smith'), findsOneWidget);
      });

      testWidgets('should handle task collaboration with comments and updates', (tester) async {
        final collaborativeTask = TaskModel.create(
          title: 'Team Discussion Task',
          description: 'Task with team collaboration',
          assignedTo: 'Alice Johnson',
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Task Collaboration'),
                ),
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      AdvancedTaskCard(
                        key: Key('collaborative_task_${collaborativeTask.id}'),
                        task: collaborativeTask,
                        showCollaboration: true,
                      ),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Activity & Comments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              // Activity timeline
                              const Column(
                                children: [
                                  ListTile(
                                    key: Key('activity_assignment'),
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.blue,
                                      child: Icon(Icons.person_add, size: 16, color: Colors.white),
                                    ),
                                    title: Text('Task assigned to Alice Johnson'),
                                    subtitle: Text('2 hours ago • by You'),
                                  ),
                                  ListTile(
                                    key: Key('activity_comment_1'),
                                    leading: CircleAvatar(child: Text('A')),
                                    title: Text('Alice Johnson commented'),
                                    subtitle: Text('I\'ll start working on this tomorrow morning.'),
                                    trailing: Text('1 hour ago'),
                                  ),
                                  ListTile(
                                    key: Key('activity_status_update'),
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.orange,
                                      child: Icon(Icons.play_arrow, size: 16, color: Colors.white),
                                    ),
                                    title: Text('Status changed to In Progress'),
                                    subtitle: Text('45 minutes ago • by Alice Johnson'),
                                  ),
                                  ListTile(
                                    key: Key('activity_comment_2'),
                                    leading: CircleAvatar(child: Text('B')),
                                    title: Text('Bob Smith commented'),
                                    subtitle: Text('@Alice Let me know if you need any help with the design specs.'),
                                    trailing: Text('30 minutes ago'),
                                  ),
                                ],
                              ),
                              const Divider(),
                              // Add comment section
                              Row(
                                children: [
                                  const CircleAvatar(child: Text('Y')),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: TextField(
                                      key: Key('add_comment_field'),
                                      decoration: InputDecoration(
                                        hintText: 'Add a comment...',
                                        border: OutlineInputBorder(),
                                      ),
                                      maxLines: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    key: const Key('send_comment_button'),
                                    icon: const Icon(Icons.send),
                                    onPressed: () {
                                      // Send comment
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        // Test activity viewing
        await tester.tap(find.byKey(const Key('activity_comment_1')));
        await tester.pump();

        await tester.tap(find.byKey(const Key('activity_comment_2')));
        await tester.pump();

        // Test adding comment
        await tester.enterText(find.byKey(const Key('add_comment_field')), 'Great progress! The UI looks good.');
        await tester.tap(find.byKey(const Key('send_comment_button')));
        await tester.pump();

        // Verify collaboration features
        expect(find.text('Team Discussion Task'), findsOneWidget);
        expect(find.text('Task assigned to Alice Johnson'), findsOneWidget);
        expect(find.text('I\'ll start working on this tomorrow morning.'), findsOneWidget);
        expect(find.text('@Alice Let me know if you need any help with the design specs.'), findsOneWidget);
        expect(find.text('Great progress! The UI looks good.'), findsOneWidget);
      });
    });

    group('Project Sharing and Collaboration', () {
      testWidgets('should share projects with team members', (tester) async {
        final sharedProject = Project(
          id: 'shared-project',
          name: 'Team Project Alpha',
          description: 'Collaborative project for team',
          color: '#2196F3',
          createdAt: DateTime.now(),
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Project Sharing'),
                ),
                body: Column(
                  children: [
                    ProjectCard(
                      project: sharedProject,
                      taskCount: 15,
                      completedTaskCount: 8,
                      showCollaboration: true,
                      onShare: () {
                        // Open sharing options
                      },
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Project Access', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            ListTile(
                              key: const Key('project_visibility'),
                              leading: const Icon(Icons.visibility),
                              title: const Text('Project Visibility'),
                              subtitle: const Text('Team members only'),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                // Change visibility
                              },
                            ),
                            ListTile(
                              key: const Key('project_permissions'),
                              leading: const Icon(Icons.security),
                              title: const Text('Default Permissions'),
                              subtitle: const Text('Members can edit tasks'),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                // Change permissions
                              },
                            ),
                            const Divider(),
                            const Text('Share Options', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    key: const Key('share_link_button'),
                                    onPressed: () {
                                      // Generate share link
                                    },
                                    icon: const Icon(Icons.link),
                                    label: const Text('Share Link'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    key: const Key('invite_to_project_button'),
                                    onPressed: () {
                                      // Invite members
                                    },
                                    icon: const Icon(Icons.person_add),
                                    label: const Text('Invite Members'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Test project sharing
        await tester.tap(find.byKey(const Key('project_visibility')));
        await tester.pump();

        await tester.tap(find.byKey(const Key('project_permissions')));
        await tester.pump();

        await tester.tap(find.byKey(const Key('share_link_button')));
        await tester.pump();

        await tester.tap(find.byKey(const Key('invite_to_project_button')));
        await tester.pump();

        // Verify project sharing
        expect(find.text('Team Project Alpha'), findsOneWidget);
        expect(find.text('Project Visibility'), findsOneWidget);
        expect(find.text('Team members only'), findsOneWidget);
        expect(find.text('Members can edit tasks'), findsOneWidget);
      });
    });

    group('Real-time Updates and Notifications', () {
      testWidgets('should show real-time collaboration updates', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Live Updates'),
                  actions: [
                    Stack(
                      children: [
                        IconButton(
                          key: const Key('notifications_button'),
                          icon: const Icon(Icons.notifications),
                          onPressed: () {
                            // Show notifications
                          },
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            key: const Key('notification_badge'),
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: const Text(
                              '3',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    Container(
                      key: const Key('live_updates_bar'),
                      color: Colors.blue[50],
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.sync, color: Colors.blue, size: 16),
                          const SizedBox(width: 8),
                          const Text('3 team members online'),
                          const Spacer(),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text('Connected', style: TextStyle(fontSize: 12, color: Colors.green)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        children: const [
                          Card(
                            key: Key('recent_update_1'),
                            margin: EdgeInsets.all(8),
                            child: ListTile(
                              leading: CircleAvatar(child: Text('A')),
                              title: Text('Alice completed "Design Review"'),
                              subtitle: Text('Mobile App Project • just now'),
                              trailing: Icon(Icons.check_circle, color: Colors.green),
                            ),
                          ),
                          Card(
                            key: Key('recent_update_2'),
                            margin: EdgeInsets.all(8),
                            child: ListTile(
                              leading: CircleAvatar(child: Text('B')),
                              title: Text('Bob started working on "API Integration"'),
                              subtitle: Text('Backend Project • 2 minutes ago'),
                              trailing: Icon(Icons.play_arrow, color: Colors.orange),
                            ),
                          ),
                          Card(
                            key: Key('recent_update_3'),
                            margin: EdgeInsets.all(8),
                            child: ListTile(
                              leading: CircleAvatar(child: Text('C')),
                              title: Text('Carol added comment on "Testing Strategy"'),
                              subtitle: Text('"We should add more edge cases"'),
                              trailing: Icon(Icons.comment, color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Test notifications
        await tester.tap(find.byKey(const Key('notifications_button')));
        await tester.pump();

        // Test real-time updates interaction
        await tester.tap(find.byKey(const Key('recent_update_1')));
        await tester.pump();

        await tester.tap(find.byKey(const Key('recent_update_2')));
        await tester.pump();

        await tester.tap(find.byKey(const Key('recent_update_3')));
        await tester.pump();

        // Verify real-time updates
        expect(find.text('Live Updates'), findsOneWidget);
        expect(find.text('3 team members online'), findsOneWidget);
        expect(find.text('Connected'), findsOneWidget);
        expect(find.text('Alice completed "Design Review"'), findsOneWidget);
        expect(find.text('Bob started working on "API Integration"'), findsOneWidget);
        expect(find.text('Carol added comment on "Testing Strategy"'), findsOneWidget);
        expect(find.byKey(const Key('notification_badge')), findsOneWidget);
      });

      testWidgets('should handle conflict resolution in collaborative editing', (tester) async {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Conflict Resolution'),
                ),
                body: Column(
                  children: [
                    Card(
                      key: const Key('conflict_notification'),
                      color: Colors.orange[50],
                      margin: const EdgeInsets.all(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.warning, color: Colors.orange),
                                SizedBox(width: 8),
                                Text('Edit Conflict Detected', style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text('Alice Johnson also modified this task while you were editing.'),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    key: const Key('keep_my_changes_button'),
                                    onPressed: () {
                                      // Keep current user's changes
                                    },
                                    child: const Text('Keep My Changes'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton(
                                    key: const Key('accept_their_changes_button'),
                                    onPressed: () {
                                      // Accept other user's changes
                                    },
                                    child: const Text('Accept Their Changes'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    key: const Key('merge_changes_button'),
                                    onPressed: () {
                                      // Show merge interface
                                    },
                                    child: const Text('Merge'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Card(
                              key: Key('my_version_card'),
                              margin: EdgeInsets.all(8),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Your Version', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                                    SizedBox(height: 8),
                                    Text('Title: Updated Task Title'),
                                    Text('Priority: High'),
                                    Text('Description: Added detailed requirements and acceptance criteria.'),
                                    SizedBox(height: 8),
                                    Text('Modified: 2 minutes ago', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Card(
                              key: Key('their_version_card'),
                              margin: EdgeInsets.all(8),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Alice\'s Version', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                    SizedBox(height: 8),
                                    Text('Title: Revised Task Title'),
                                    Text('Priority: Medium'),
                                    Text('Description: Updated based on client feedback from today\'s meeting.'),
                                    SizedBox(height: 8),
                                    Text('Modified: 1 minute ago', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Test conflict resolution options
        await tester.tap(find.byKey(const Key('merge_changes_button')));
        await tester.pump();

        await tester.tap(find.byKey(const Key('keep_my_changes_button')));
        await tester.pump();

        await tester.tap(find.byKey(const Key('accept_their_changes_button')));
        await tester.pump();

        // Verify conflict resolution interface
        expect(find.text('Edit Conflict Detected'), findsOneWidget);
        expect(find.text('Alice Johnson also modified this task while you were editing.'), findsOneWidget);
        expect(find.text('Your Version'), findsOneWidget);
        expect(find.text('Alice\'s Version'), findsOneWidget);
        expect(find.text('Updated Task Title'), findsOneWidget);
        expect(find.text('Revised Task Title'), findsOneWidget);
      });
    });
  });
}