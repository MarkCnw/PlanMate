import 'package:flutter/material.dart';
import 'package:planmate/Models/project_model.dart';
import 'package:planmate/Search/Widgets/search_results_widget.dart';
import 'package:planmate/Search/Widgets/search_widget.dart';
import 'package:planmate/provider/project_provider.dart';
import 'package:planmate/CreateProject/Presentation/project_screen.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _searchQuery = '';
  List<ProjectModel> _searchResults = [];
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf9f4ef),
      appBar: AppBar(
        backgroundColor: const Color(0xFFf9f4ef),
        elevation: 0,
        title: const Text(
          'Search Projects',
          style: TextStyle(
            color: Color(0xFF001858),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF001858)),
        //   onPressed: () => Navigator.pop(context),
        // ),
      ),
      body: Column(
        children: [
          // Search Input
          ProjectSearchWidget(onSearchChanged: _onSearchChanged),
          
          // Search Results
          Expanded(
            child: Consumer<ProjectProvider>(
              builder: (context, projectProvider, child) {
                return SearchResultsWidget(
                  searchResults: _searchResults,
                  searchQuery: _searchQuery,
                  onProjectTap: _onProjectTap,
                  isSearching: _isSearching,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _isSearching = true;
    });

    // Debounce search (รอ 300ms ก่อนค้นหาจริง)
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && _searchQuery == query) {
        _performSearch(query);
      }
    });
  }

  void _performSearch(String query) {
    final projectProvider = context.read<ProjectProvider>();
    final results = projectProvider.searchProjects(query);
    
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  void _onClearSearch() {
    setState(() {
      _searchQuery = '';
      _searchResults = [];
      _isSearching = false;
    });
  }

  void _onProjectTap(ProjectModel project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectScreenDetail(project: project),
      ),
    );
  }
}