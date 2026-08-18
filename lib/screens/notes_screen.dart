// ============================================================
// مسیر: lib/screens/notes_screen.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/date_provider.dart';
import '../models/note.dart';
import 'add_note_screen.dart';
import 'note_categories_screen.dart';
import 'package:ei_app/providers/providers.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  String _selectedCategoryId = '';
  String _searchQuery = '';
  int _currentPage = 1;
  int _pageSize = 10;

  List<Note> get _filteredNotes {
    var list = context.watch<DataProvider>().notes;

    if (_selectedCategoryId.isNotEmpty) {
      list = list.where((n) => n.categoryId == _selectedCategoryId).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      list = list.where((n) =>
        n.title.toLowerCase().contains(query) ||
        n.body.toLowerCase().contains(query)
      ).toList();
    }

    list.sort((a, b) => b.updated.compareTo(a.updated));
    return list;
  }

  List<Note> get _pageItems {
    final total = _filteredNotes.length;
    final totalPages = (total / _pageSize).ceil();
    if (_currentPage > totalPages) _currentPage = totalPages;
    if (_currentPage < 1) _currentPage = 1;

    final start = (_currentPage - 1) * _pageSize;
    final end = start + _pageSize;
    return _filteredNotes.sublist(
      start,
      end > total ? total : end,
    );
  }

  int get _totalPages {
    return (_filteredNotes.length / _pageSize).ceil();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final theme = context.watch<ThemeProvider>();
    final dateProvider = context.watch<DateProvider>();
    final isDark = theme.isDarkMode(context);

    final notes = _pageItems;
    final categories = data.noteCategories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('یادداشت‌ها'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NoteCategoriesScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'جستجو در یادداشت‌ها...',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _currentPage = 1;
                });
              },
            ),
          ),

          if (categories.isNotEmpty)
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCategoryChip('همه', ''),
                  ...categories.map((c) => _buildCategoryChip(c.name, c.id, color: c.color)),
                ],
              ),
            ),

          const SizedBox(height: 4),

          Expanded(
            child: notes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_alt_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isNotEmpty || _selectedCategoryId.isNotEmpty
                              ? 'نتیجه‌ای یافت نشد'
                              : 'هنوز یادداشتی ثبت نشده',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty || _selectedCategoryId.isNotEmpty
                              ? 'جستجوی خود را تغییر دهید'
                              : 'با دکمه + یک یادداشت جدید اضافه کنید',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      final category = data.getNoteCategory(note.categoryId);

                      return Material(
                        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddNoteScreen(note: note),
                              ),
                            ).then((_) => setState(() {}));
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.06),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                if (category != null)
                                  Container(
                                    width: 4,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: _hexToColor(category.color),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        note.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        note.body,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 13,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          if (category != null)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: _hexToColor(category.color).withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                category.name,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: _hexToColor(category.color),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          if (category != null) const SizedBox(width: 6),
                                          Text(
                                            '${dateProvider.convertDate(note.updated.split(' ')[0], dateProvider.currentFormat)}',
                                            style: TextStyle(
                                              color: Colors.grey.shade500,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                  color: Colors.grey.shade400,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          if (_filteredNotes.length > _pageSize)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _currentPage > 1
                        ? () => setState(() => _currentPage--)
                        : null,
                  ),
                  Text(
                    'صفحه $_currentPage از $_totalPages',
                    style: const TextStyle(fontSize: 13),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _currentPage < _totalPages
                        ? () => setState(() => _currentPage++)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'کل: ${_filteredNotes.length}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddNoteScreen(),
            ),
          ).then((_) => setState(() {}));
        },
        backgroundColor: const Color(0xFF6C5CE7),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryChip(String label, String id, {String color = '#6C5CE7'}) {
    final isSelected = _selectedCategoryId == id;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategoryId = selected ? id : '';
            _currentPage = 1;
          });
        },
        selectedColor: _hexToColor(color),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : null,
          fontSize: 12,
        ),
        side: BorderSide(
          color: isSelected ? _hexToColor(color) : Colors.grey.shade300,
        ),
      ),
    );
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}