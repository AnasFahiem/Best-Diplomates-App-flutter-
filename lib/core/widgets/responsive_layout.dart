import 'package:flutter/material.dart';
import '../constants/responsive_constants.dart';
import '../utils/responsive_utils.dart';

/// A widget that builds different layouts for mobile, tablet, and desktop
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context) mobile;
  final Widget Function(BuildContext context)? tablet;
  final Widget Function(BuildContext context)? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    if (context.isDesktop && desktop != null) {
      return desktop!(context);
    } else if (context.isTablet && tablet != null) {
      return tablet!(context);
    }
    return mobile(context);
  }
}

/// A container that constrains width on larger screens
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;
  final bool centerOnDesktop;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.centerOnDesktop = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveMaxWidth = maxWidth ?? ResponsiveBreakpoints.maxContentWidth;
    
    Widget content = child;
    
    // Add padding if provided
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }
    
    // Constrain width on desktop
    if (context.isDesktop && centerOnDesktop) {
      content = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
          child: content,
        ),
      );
    } else if (context.isDesktop) {
      content = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
        child: content,
      );
    }
    
    return content;
  }
}

/// A responsive grid that adapts column count based on screen size
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;
  final double? childAspectRatio;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
    this.childAspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    final columns = context.responsiveValue(
      mobile: mobileColumns ?? 1,
      tablet: tabletColumns ?? 2,
      desktop: desktopColumns ?? 3,
    );

    final spacing = ResponsiveUtils.spacing(context);

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: crossAxisSpacing ?? spacing,
        mainAxisSpacing: mainAxisSpacing ?? spacing,
        childAspectRatio: childAspectRatio ?? 1.0,
      ),
      itemCount: children.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// A responsive padding widget
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final double? mobile;
  final double? tablet;
  final double? desktop;
  final bool horizontal;
  final bool vertical;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobile,
    this.tablet,
    this.desktop,
    this.horizontal = false,
    this.vertical = false,
  });

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding;
    
    if (horizontal) {
      padding = ResponsiveUtils.horizontalPadding(
        context,
        mobile: mobile,
        tablet: tablet,
        desktop: desktop,
      );
    } else if (vertical) {
      padding = ResponsiveUtils.verticalPadding(
        context,
        mobile: mobile,
        tablet: tablet,
        desktop: desktop,
      );
    } else {
      padding = ResponsiveUtils.padding(
        context,
        mobile: mobile,
        tablet: tablet,
        desktop: desktop,
      );
    }

    return Padding(
      padding: padding,
      child: child,
    );
  }
}

/// A widget that provides responsive spacing
class ResponsiveSpacing extends StatelessWidget {
  final double? mobile;
  final double? tablet;
  final double? desktop;
  final bool horizontal;

  const ResponsiveSpacing({
    super.key,
    this.mobile,
    this.tablet,
    this.desktop,
    this.horizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveUtils.spacing(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );

    return SizedBox(
      width: horizontal ? spacing : null,
      height: horizontal ? null : spacing,
    );
  }
}
