import 'package:flutter/material.dart';
import 'package:money_mate/screens/widgets/add_asset_bottom_sheet.dart';
import 'package:money_mate/screens/widgets/asset_allocation_bar_chart.dart';
import 'package:money_mate/screens/widgets/asset_allocation_sections_list.dart';
import 'package:money_mate/screens/widgets/asset_summary_card.dart';

class AssetsTabScreen extends StatelessWidget {
  const AssetsTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 140),
        children: [
          const _HeaderSection(),
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

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '내 자산',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}
