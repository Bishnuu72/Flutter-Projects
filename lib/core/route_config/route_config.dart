import 'package:flutter/material.dart';
import 'package:manshi/core/route_config/routes_name.dart';
import 'package:manshi/screens/dashboard_screen.dart';
import 'package:manshi/screens/login_screen.dart';
import 'package:manshi/screens/preference_selection.dart';
import 'package:manshi/screens/product/product_screen.dart';
import 'package:manshi/screens/profile_screen.dart';
import 'package:manshi/screens/quotes_detail_screen.dart';
import 'package:manshi/screens/register_screen.dart';

class RouteConfig {
  RouteConfig._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final String? screenName = settings.name;
    final dynamic args = settings.arguments;

    switch (screenName) {
      case RoutesName.loginScreen:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case RoutesName.registerScreen:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case RoutesName.preferenceSelection:
        return MaterialPageRoute(builder: (_) => const PreferenceSelection());

      case RoutesName.dashboardScreen:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());

      case RoutesName.profileScreen:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case RoutesName.quotesDetailScreen:
        return MaterialPageRoute(builder: (_) => const QuotesDetailScreen());

      case RoutesName.productScreen:
        return MaterialPageRoute(builder: (_) => const ProductScreen());

      case RoutesName.defaultScreen:
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}
