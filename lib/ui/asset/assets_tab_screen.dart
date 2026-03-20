import 'package:flutter/material.dart';
import 'package:money_mate/ui/asset/asset_allocation_bar_chart.dart';
import 'package:money_mate/ui/asset/asset_summary_card.dart';
import 'package:money_mate/ui/core/tab_header_section.dart';

import 'add_asset_bottom_sheet.dart';
import 'asset_allocation_sections_list.dart';

class AssetsTabScreen extends StatelessWidget {
  const AssetsTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 140),
        children: [
          const TabHeaderSection(title: '내 자산'),
          const SizedBox(height: 20),
          const AssetSummaryCard(),
          const SizedBox(height: 16),
          AssetAllocationBarChart(
            onAddAssetTap: () => showAddAssetBottomSheet(context),
          ),
          const SizedBox(height: 20),
          const AssetAllocationSectionsList(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
