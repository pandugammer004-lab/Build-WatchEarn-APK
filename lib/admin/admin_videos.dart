import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/widgets/custom_button.dart';
import '../core/widgets/custom_text_field.dart';

class AdminVideos extends StatefulWidget {
  const AdminVideos({Key? key}) : super(key: key);

  @override
  State<AdminVideos> createState() => _AdminVideosState();
}

class _AdminVideosState extends State<AdminVideos> {
  void _showAddVideoDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddVideoDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('🎬 Video Management', style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: _showAddVideoDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add New Video', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search by title or YouTube ID...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.search, color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                child: DropdownButton<String>(
                  value: 'All Categories',
                  dropdownColor: const Color(0xFF1A1A2E),
                  style: const TextStyle(color: Colors.white),
                  underline: const SizedBox(),
                  items: ['All Categories', 'Satisfying', 'Gaming', 'Music'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (_) {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(Colors.black12),
                      dataRowHeight: 80,
                      columns: const [
                        DataColumn(label: Text('Thumbnail', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Title', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Category', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Views', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Flags', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Actions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      ],
                      rows: [
                        _buildVideoRow('Oddly Satisfying Sand', 'Satisfying', 14500, true, true, false),
                        _buildVideoRow('Top 10 Gaming Moments', 'Gaming', 8900, true, false, false),
                        _buildVideoRow('Exclusive ASMR (VIP)', 'Satisfying', 4200, true, true, true),
                        _buildVideoRow('Broken Video Link', 'Music', 0, false, false, false),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildVideoRow(String title, String category, int views, bool isActive, bool isTrending, bool isVip) {
    return DataRow(cells: [
      DataCell(
        Container(
          width: 100,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(8),
            image: const DecorationImage(
              image: NetworkImage('https://via.placeholder.com/100x56'),
              fit: BoxFit.cover,
            ),
          ),
          child: const Center(child: Icon(Icons.play_arrow, color: Colors.white, size: 24)),
        ),
      ),
      DataCell(SizedBox(width: 250, child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis))),
      DataCell(Chip(label: Text(category, style: const TextStyle(fontSize: 10, color: Colors.white)), backgroundColor: Colors.white10)),
      DataCell(Text('$views', style: const TextStyle(color: Colors.white70))),
      DataCell(
        Switch(value: isActive, onChanged: (_) {}, activeColor: Colors.green),
      ),
      DataCell(
        Row(
          children: [
            if (isTrending) const Icon(Icons.trending_up, color: Colors.orange, size: 16),
            if (isVip) const Padding(padding: EdgeInsets.only(left: 4), child: Icon(Icons.workspace_premium, color: Colors.amber, size: 16)),
          ],
        ),
      ),
      DataCell(
        Row(
          children: [
            IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () {}, tooltip: 'Edit'),
            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () {}, tooltip: 'Delete'),
          ],
        ),
      ),
    ]);
  }
}

class AddVideoDialog extends StatelessWidget {
  const AddVideoDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Add New Video', style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      const CustomTextField(hintText: 'Direct MP4 URL', prefixIcon: Icons.link),
                      const SizedBox(height: 16),
                      const CustomTextField(hintText: 'Thumbnail Image URL', prefixIcon: Icons.image),
                      const SizedBox(height: 16),
                      const CustomTextField(hintText: 'Video Title', prefixIcon: Icons.title),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: 'Cricket Shorts',
                          dropdownColor: const Color(0xFF1A1A2E),
                          style: const TextStyle(color: Colors.white),
                          underline: const SizedBox(),
                          items: ['Cricket Shorts', 'Football Shorts', 'Funny Videos'].map((String value) {
                            return DropdownMenuItem<String>(value: value, child: Text(value));
                          }).toList(),
                          onChanged: (_) {},
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildCheckbox('Trending', true)),
                          Expanded(child: _buildCheckbox('VIP Only', false)),
                          Expanded(child: _buildCheckbox('Active', true)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      const Text('Thumbnail Preview', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 8),
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: const Center(
                          child: Text('Preview Image', style: TextStyle(color: Colors.white38, fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
                const SizedBox(width: 16),
                CustomButton(text: 'Save Video', onPressed: () => Navigator.pop(context), width: 150),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox(String label, bool value) {
    return Row(
      children: [
        Checkbox(value: value, onChanged: (_) {}, activeColor: AppColors.primary),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
