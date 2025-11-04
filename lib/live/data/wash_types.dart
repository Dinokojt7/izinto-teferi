import 'package:flutter/material.dart';

final List<Map<String, dynamic>> washTypes = [
  {
    'washType': 'Standard Interior Wash',
    'description': 'Inside wash only, includes dashboard clean.',
    'included': [
      {
        'text': 'Vacuuming',
        'image': 'assets/image/vacuuming.png',
        'color': Colors.deepPurpleAccent.withOpacity(0.2)
      },
      {
        'text': 'DashBoard clean',
        'image': 'assets/image/dashboard-clean.png',
        'color': Colors.redAccent.withOpacity(0.2)
      },
      {
        'text': 'Seats clean',
        'image': 'assets/image/seat-clean.png',
        'color': Colors.green.shade100
      },
    ],
    'excluded': []
  }, //example of Standard Interior wash details
  {
    'washType': 'Standard Exterior Wash',
    'description': 'Outside wash only, includes tyre shine.',
    'included': [
      {
        'text': 'Full Body Wash',
        'image': 'assets/image/full-body-wash.png',
        'color': Colors.orange.withOpacity(0.2)
      },
      {
        'text': 'Tyre Polish',
        'image': 'assets/image/tyre-shine.png',
        'color': Colors.blueGrey.withOpacity(0.2)
      },
    ],
    'excluded': []
  }, //example of Standard Exterior Wash details
  {
    'washType': 'Standard Exterior Wash and Polish',
    'description': 'Outside wash only, includes tyre shine and body polish.',
    'included': [
      {
        'text': 'Body Polish',
        'image': 'assets/image/body-polish.png',
        'color': Colors.green.shade100
      },
      {
        'text': 'Full Body Wash',
        'image': 'assets/image/full-body-wash.png',
        'color': Colors.orange.withOpacity(0.2)
      },
      {
        'text': 'Tyre Polish',
        'image': 'assets/image/tyre-shine.png',
        'color': Colors.redAccent.withOpacity(0.2)
      },
    ],
    'excluded': []
  }, //example of Standard Exterior and Wash Polish details
  {
    'washType': 'Standard Full Wash',
    'description': 'Full car wash including vacuuming and tyre shine.',
    'included': [
      {
        'text': 'Tyre Shine',
        'image': 'assets/image/tyre-shine.png',
        'color': Colors.redAccent.withOpacity(0.2)
      },
      {
        'text': 'Full Body Wash',
        'image': 'assets/image/full-body-wash.png',
        'color': Colors.orange.withOpacity(0.2)
      },
      {
        'text': 'Vacuuming',
        'image': 'assets/image/vacuuming.png',
        'color': Colors.blueGrey.withOpacity(0.2)
      },
      {
        'text': 'DashBoard clean',
        'image': 'assets/image/dashboard-clean.png',
        'color': Colors.redAccent.withOpacity(0.2)
      },
      {
        'text': 'Seats clean',
        'image': 'assets/image/seat-clean.png',
        'color': Colors.green.shade100
      },
    ],
    'excluded': []
  }, //example of Standard Full Wash details
  {
    'washType': 'Standard Wash and Full Body Polish',
    'description':
        'Full car wash including vacuuming, tyre shine, and body polish.',
    'included': [
      {
        'text': 'Body Polish',
        'image': 'assets/image/body-polish.png',
        'color': Colors.green.shade100
      },
      {
        'text': 'Full Body Wash',
        'image': 'assets/image/full-body-wash.png',
        'color': Colors.orange.withOpacity(0.2)
      },
      {
        'text': 'Vacuuming',
        'image': 'assets/image/vacuuming.png',
        'color': Colors.blueGrey.withOpacity(0.2)
      },
      {
        'text': 'DashBoard clean',
        'image': 'assets/image/dashboard-clean.png',
        'color': Colors.redAccent.withOpacity(0.2)
      },
      {
        'text': 'Seats clean',
        'image': 'assets/image/seat-clean.png',
        'color': Colors.green.shade100
      },
      {
        'text': 'Tyre Shine',
        'image': 'assets/image/tyre-shine.png',
        'color': Colors.redAccent.withOpacity(0.2)
      },
    ],
    'excluded': []
  }, //example of Standard Wash and Full Body Polish details
  {
    'washType': 'Premium Full Wash',
    'description':
        'Full car wash including vacuuming, tyre shine, and premium perfumes.',
    'included': [
      {
        'text': 'Premium Perfumes',
        'image': 'assets/image/perfume.png',
        'color': Colors.brown.shade100
      },
      {
        'text': 'Full Body Wash',
        'image': 'assets/image/full-body-wash.png',
        'color': Colors.orange.withOpacity(0.2)
      },
      {
        'text': 'Vacuuming',
        'image': 'assets/image/vacuuming.png',
        'color': Colors.blueGrey.withOpacity(0.2)
      },
      {
        'text': 'DashBoard clean',
        'image': 'assets/image/dashboard-clean.png',
        'color': Colors.redAccent.withOpacity(0.2)
      },
      {
        'text': 'Seats clean',
        'image': 'assets/image/seat-clean.png',
        'color': Colors.green.shade100
      },
      {
        'text': 'Tyre Shine',
        'image': 'assets/image/tyre-shine.png',
        'color': Colors.redAccent.withOpacity(0.2)
      },
    ],
    'excluded': []
  }, //example of Premium Full Wash details
  {
    'washType': 'Premium Full Wash and Full Body Polish',
    'description':
        'Full car wash including vacuuming, tyre shine, premium perfumes, and body polish.',
    'included': [
      {
        'text': 'Body Polish',
        'image': 'assets/image/body-polish.png',
        'color': Colors.green.shade100
      },
      {
        'text': 'Premium Perfumes',
        'image': 'assets/image/perfume.png',
        'color': Colors.brown.shade100
      },
      {
        'text': 'Full Body Wash',
        'image': 'assets/image/full-body-wash.png',
        'color': Colors.orange.withOpacity(0.2)
      },
      {
        'text': 'Vacuuming',
        'image': 'assets/image/vacuuming.png',
        'color': Colors.blueGrey.withOpacity(0.2)
      },
      {
        'text': 'DashBoard clean',
        'image': 'assets/image/dashboard-clean.png',
        'color': Colors.redAccent.withOpacity(0.2)
      },
      {
        'text': 'Seats clean',
        'image': 'assets/image/seat-clean.png',
        'color': Colors.green.shade100
      },
      {
        'text': 'Tyre Shine',
        'image': 'assets/image/tyre-shine.png',
        'color': Colors.redAccent.withOpacity(0.2)
      },
    ],
    'excluded': []
  }, //example of Premium Full Wash and Full Body Polish details
];
