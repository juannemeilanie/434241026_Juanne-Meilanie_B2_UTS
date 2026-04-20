import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF1E88E5);
  static const Color primaryDark = Color(0xFF0D47A1);

  static const Color secondary = Color(0xFF0288D1);

  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);

  static const Color warning = Color(0xFFF57F17);
  static const Color warningLight = Color(0xFFFFF8E1);

  static const Color error = Color(0xFFC62828);
  static const Color errorLight = Color(0xFFFFEBEE);

  static const Color info = Color(0xFF0277BD);
  static const Color infoLight = Color(0xFFE1F5FE);

  static const Color grey = Color(0xFF757575);
  static const Color greyLight = Color(0xFFF5F5F5);
  static const Color greyBorder = Color(0xFFE0E0E0);

  // Status colors
  static Color statusColor(String status) {
    switch (status) {
      case 'open':
        return const Color(0xFF1565C0);
      case 'in_progress':
        return const Color(0xFFF57F17);
      case 'resolved':
        return const Color(0xFF2E7D32);
      case 'closed':
        return const Color(0xFF757575);
      default:
        return const Color(0xFF757575);
    }
  }

  static Color statusBgColor(String status) {
    switch (status) {
      case 'open':
        return const Color(0xFFE3F2FD);
      case 'in_progress':
        return const Color(0xFFFFF8E1);
      case 'resolved':
        return const Color(0xFFE8F5E9);
      case 'closed':
        return const Color(0xFFF5F5F5);
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  static Color priorityColor(String priority) {
    switch (priority) {
      case 'critical':
        return const Color(0xFFB71C1C);
      case 'high':
        return const Color(0xFFC62828);
      case 'medium':
        return const Color(0xFFF57F17);
      case 'low':
        return const Color(0xFF2E7D32);
      default:
        return const Color(0xFF757575);
    }
  }

  static Color priorityBgColor(String priority) {
    switch (priority) {
      case 'critical':
        return const Color(0xFFFFEBEE);
      case 'high':
        return const Color(0xFFFFEBEE);
      case 'medium':
        return const Color(0xFFFFF8E1);
      case 'low':
        return const Color(0xFFE8F5E9);
      default:
        return const Color(0xFFF5F5F5);
    }
  }
}

// ─────────────────────────────────────────
// LABEL STATUS & PRIORITY
// ─────────────────────────────────────────
class TicketConstants {
  TicketConstants._();

  static const List<String> statuses = [
    'open',
    'in_progress',
    'resolved',
    'closed',
  ];

  static const List<String> priorities = [
    'low',
    'medium',
    'high',
    'critical',
  ];

  static String statusLabel(String status) {
    switch (status) {
      case 'open':
        return 'Open';
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      case 'closed':
        return 'Closed';
      default:
        return status;
    }
  }

  static String priorityLabel(String priority) {
    switch (priority) {
      case 'low':
        return 'Low';
      case 'medium':
        return 'Medium';
      case 'high':
        return 'High';
      case 'critical':
        return 'Critical';
      default:
        return priority;
    }
  }

  static int statusIndex(String status) {
    return statuses.indexOf(status);
  }
}

// ─────────────────────────────────────────
// STRING UMUM
// ─────────────────────────────────────────
class AppStrings {
  AppStrings._();

  static const String appName = 'E-Ticketing Helpdesk';
  static const String appSubtitle = 'Universitas Airlangga';

  static const String login = 'Login';
  static const String logout = 'Logout';
  static const String register = 'Daftar';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String name = 'Nama Lengkap';
  static const String forgotPassword = 'Lupa Password?';
  static const String noAccount = 'Belum punya akun? ';
  static const String haveAccount = 'Sudah punya akun? ';

  static const String dashboard = 'Dashboard';
  static const String tickets = 'Tiket';
  static const String notifications = 'Notifikasi';
  static const String profile = 'Profil';

  static const String createTicket = 'Buat Tiket Baru';
  static const String ticketTitle = 'Judul';
  static const String ticketDescription = 'Deskripsi';
  static const String ticketCategory = 'Kategori';
  static const String ticketPriority = 'Prioritas';
  static const String ticketAttachment = 'Lampiran';

  static const String submit = 'Kirim Tiket';
  static const String cancel = 'Batal';
  static const String save = 'Simpan';
  static const String close = 'Tutup';

  static const String search = 'Cari tiket...';
  static const String allStatus = 'Semua';
  static const String noTicket = 'Belum ada tiket';
  static const String noNotification = 'Tidak ada notifikasi';

  static const String addComment = 'Tulis komentar...';
  static const String send = 'Kirim';

  static const String darkMode = 'Dark Mode';
  static const String notificationSetting = 'Notifikasi';
  static const String changePassword = 'Ubah Password';
  static const String version = 'Versi 1.0.0';
}