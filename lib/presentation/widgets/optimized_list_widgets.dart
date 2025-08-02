import 'package:flutter/material.dart';
import '../../services/performance_service.dart';

/// Optimized list view for large datasets with performance monitoring
class OptimizedListView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final double? itemExtent;
  final ScrollController? controller;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final int? cacheExtent;
  final String? performanceTag;
  final VoidCallback? onScrollEnd;
  final bool enableLazyLoading;
  final int lazyLoadThreshold;
  
  const OptimizedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.itemExtent,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.cacheExtent,
    this.performanceTag,
    this.onScrollEnd,
    this.enableLazyLoading = false,
    this.lazyLoadThreshold = 10,
  });
  @override
  State<OptimizedListView<T>> createState() => _OptimizedListViewState<T>();
}

class _OptimizedListViewState<T> extends State<OptimizedListView<T>> {
  late ScrollController _controller;
  final Map<int, Widget> _cachedWidgets = {};
  final PerformanceService _performanceService = PerformanceService();
  bool _isScrolling = false;
  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ScrollController();
    _controller.addListener(_onScroll);
    
    // Start performance monitoring
    if (widget.performanceTag != null) {
      _performanceService.startTimer('list_render_${widget.performanceTag}');
    }
  }
  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    if (widget.controller == null) {
      _controller.dispose();
    }
    
    // Stop performance monitoring
    if (widget.performanceTag != null) {
      _performanceService.stopTimer('list_render_${widget.performanceTag}');
    }
    
    super.dispose();
  }
  
  void _onScroll() {
    if (!_isScrolling) {
      _isScrolling = true;
      _performanceService.startTimer('list_scroll_${widget.performanceTag ?? 'default'}');
    }
    
    // Detect scroll end for lazy loading
    if (widget.enableLazyLoading && 
        _controller.position.pixels >= _controller.position.maxScrollExtent - (widget.lazyLoadThreshold * (widget.itemExtent ?? 60))) {
      widget.onScrollEnd?.call();
    }
    
    // Debounce scroll end detection
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_isScrolling && _controller.position.activity?.isScrolling == false) {
        _isScrolling = false;
        _performanceService.stopTimer('list_scroll_${widget.performanceTag ?? 'default'}');
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _controller,
      itemCount: widget.items.length,
      itemExtent: widget.itemExtent,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      cacheExtent: widget.cacheExtent?.toDouble() ?? 250.0, // Optimized cache extent
      itemBuilder: (context, index) {
        return _buildOptimizedItem(context, index);
      },
    );
  }
  
  Widget _buildOptimizedItem(BuildContext context, int index) {
    // Use RepaintBoundary to isolate repaints
    return RepaintBoundary(
      child: _buildCachedItem(context, index),
    );
  }
  
  Widget _buildCachedItem(BuildContext context, int index) {
    // Implement intelligent caching
    final cacheKey = index;
    
    if (!_cachedWidgets.containsKey(cacheKey)) {
      _cachedWidgets[cacheKey] = widget.itemBuilder(context, widget.items[index], index);
      
      // Limit cache size to prevent memory issues
      if (_cachedWidgets.length > 200) {
        // Remove oldest cached items
        final keysToRemove = _cachedWidgets.keys.take(_cachedWidgets.length - 150).toList();
        for (final key in keysToRemove) {
          _cachedWidgets.remove(key);
        }
      }
    }
    
    return _cachedWidgets[cacheKey]!;
  }
}

/// Optimized grid view for large datasets
class OptimizedGridView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final SliverGridDelegate gridDelegate;
  final ScrollController? controller;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final String? performanceTag;
  
  const OptimizedGridView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.gridDelegate,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.performanceTag,
  });
  @override
  State<OptimizedGridView<T>> createState() => _OptimizedGridViewState<T>();
}

class _OptimizedGridViewState<T> extends State<OptimizedGridView<T>> {
  late ScrollController _controller;
  final Map<int, Widget> _cachedWidgets = {};
  final PerformanceService _performanceService = PerformanceService();
  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ScrollController();
    
    if (widget.performanceTag != null) {
      _performanceService.startTimer('grid_render_${widget.performanceTag}');
    }
  }
  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    
    if (widget.performanceTag != null) {
      _performanceService.stopTimer('grid_render_${widget.performanceTag}');
    }
    
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: _controller,
      itemCount: widget.items.length,
      gridDelegate: widget.gridDelegate,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      cacheExtent: 500.0, // Optimized for grid
      itemBuilder: (context, index) {
        return RepaintBoundary(
          child: _buildCachedItem(context, index),
        );
      },
    );
  }
  
  Widget _buildCachedItem(BuildContext context, int index) {
    final cacheKey = index;
    
    if (!_cachedWidgets.containsKey(cacheKey)) {
      _cachedWidgets[cacheKey] = widget.itemBuilder(context, widget.items[index], index);
      
      // Limit cache size
      if (_cachedWidgets.length > 100) {
        final keysToRemove = _cachedWidgets.keys.take(_cachedWidgets.length - 75).toList();
        for (final key in keysToRemove) {
          _cachedWidgets.remove(key);
        }
      }
    }
    
    return _cachedWidgets[cacheKey]!;
  }
}

/// Optimized sliver list for complex scrollable layouts
class OptimizedSliverList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final String? performanceTag;
  
  const OptimizedSliverList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.performanceTag,
  });
  @override
  State<OptimizedSliverList<T>> createState() => _OptimizedSliverListState<T>();
}

class _OptimizedSliverListState<T> extends State<OptimizedSliverList<T>> {
  final Map<int, Widget> _cachedWidgets = {};
  final PerformanceService _performanceService = PerformanceService();
  @override
  void initState() {
    super.initState();
    
    if (widget.performanceTag != null) {
      _performanceService.startTimer('sliver_render_${widget.performanceTag}');
    }
  }
  @override
  void dispose() {
    if (widget.performanceTag != null) {
      _performanceService.stopTimer('sliver_render_${widget.performanceTag}');
    }
    
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return RepaintBoundary(
            child: _buildCachedItem(context, index),
          );
        },
        childCount: widget.items.length,
      ),
    );
  }
  
  Widget _buildCachedItem(BuildContext context, int index) {
    final cacheKey = index;
    
    if (!_cachedWidgets.containsKey(cacheKey)) {
      _cachedWidgets[cacheKey] = widget.itemBuilder(context, widget.items[index], index);
      
      // Limit cache size
      if (_cachedWidgets.length > 150) {
        final keysToRemove = _cachedWidgets.keys.take(_cachedWidgets.length - 100).toList();
        for (final key in keysToRemove) {
          _cachedWidgets.remove(key);
        }
      }
    }
    
    return _cachedWidgets[cacheKey]!;
  }
}

/// Performance-optimized animated list
class OptimizedAnimatedList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index, Animation<double> animation) itemBuilder;
  final Widget Function(BuildContext context, T item, int index, Animation<double> animation)? removedItemBuilder;
  final Duration insertDuration;
  final Duration removeDuration;
  final String? performanceTag;
  
  const OptimizedAnimatedList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.removedItemBuilder,
    this.insertDuration = const Duration(milliseconds: 300),
    this.removeDuration = const Duration(milliseconds: 300),
    this.performanceTag,
  });
  @override
  State<OptimizedAnimatedList<T>> createState() => _OptimizedAnimatedListState<T>();
}

class _OptimizedAnimatedListState<T> extends State<OptimizedAnimatedList<T>> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final PerformanceService _performanceService = PerformanceService();
  List<T> _items = [];
  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
    
    if (widget.performanceTag != null) {
      _performanceService.startTimer('animated_list_render_${widget.performanceTag}');
    }
  }
  @override
  void didUpdateWidget(OptimizedAnimatedList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateList(oldWidget.items, widget.items);
  }
  @override
  void dispose() {
    if (widget.performanceTag != null) {
      _performanceService.stopTimer('animated_list_render_${widget.performanceTag}');
    }
    
    super.dispose();
  }
  
  void _updateList(List<T> oldItems, List<T> newItems) {
    // Efficient list diffing and animation
    final oldSet = Set.from(oldItems);
    final newSet = Set.from(newItems);
    
    // Handle removals
    for (int i = oldItems.length - 1; i >= 0; i--) {
      if (!newSet.contains(oldItems[i])) {
        final removedItem = _items.removeAt(i);
        _listKey.currentState?.removeItem(
          i,
          (context, animation) => widget.removedItemBuilder?.call(context, removedItem, i, animation) ??
              widget.itemBuilder(context, removedItem, i, animation),
          duration: widget.removeDuration,
        );
      }
    }
    
    // Handle insertions
    for (int i = 0; i < newItems.length; i++) {
      if (!oldSet.contains(newItems[i])) {
        _items.insert(i, newItems[i]);
        _listKey.currentState?.insertItem(i, duration: widget.insertDuration);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      initialItemCount: _items.length,
      itemBuilder: (context, index, animation) {
        if (index >= _items.length) return const SizedBox.shrink();
        
        return RepaintBoundary(
          child: widget.itemBuilder(context, _items[index], index, animation),
        );
      },
    );
  }
}

/// Lazy loading wrapper for infinite scroll
class LazyLoadingWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onLoadMore;
  final bool isLoading;
  final bool hasMore;
  final Widget? loadingWidget;
  final double threshold;
  
  const LazyLoadingWrapper({
    super.key,
    required this.child,
    required this.onLoadMore,
    required this.isLoading,
    required this.hasMore,
    this.loadingWidget,
    this.threshold = 200.0,
  });
  @override
  State<LazyLoadingWrapper> createState() => _LazyLoadingWrapperState();
}

class _LazyLoadingWrapperState extends State<LazyLoadingWrapper> {
  final ScrollController _controller = const ScrollController();
  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }
  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_controller.position.pixels >= _controller.position.maxScrollExtent - widget.threshold) {
      if (!widget.isLoading && widget.hasMore) {
        widget.onLoadMore();
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: widget.child),
        if (widget.isLoading)
          widget.loadingWidget ?? 
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}