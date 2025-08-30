import 'package:flutter/material.dart';
import 'package:planmate/Home/Widgets/ProjectSection/project_card_widget.dart';
import 'package:planmate/Models/project_model.dart';


class SearchResultsWidget extends StatelessWidget {
  final List<ProjectModel> searchResults;
  final String searchQuery;
  final Function(ProjectModel) onProjectTap;
  final bool isSearching;

  const SearchResultsWidget({
    super.key,
    required this.searchResults,
    required this.searchQuery,
    required this.onProjectTap,
    this.isSearching = false,
  });

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (isSearching) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
          ),
        ),
      );
    }

    // Empty search query
    if (searchQuery.trim().isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search,
                size: 64,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                'Search your projects',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Type project name to find it quickly',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // No results found
    if (searchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                'No projects found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: 'No projects match "',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                  children: [
                    TextSpan(
                      text: searchQuery,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                    const TextSpan(text: '"'),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Search results
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Results header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: RichText(
            text: TextSpan(
              text: 'Found ',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              children: [
                TextSpan(
                  text: '${searchResults.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B5CF6),
                  ),
                ),
                TextSpan(
                  text: searchResults.length == 1 ? ' project' : ' projects',
                ),
                const TextSpan(text: ' for "'),
                TextSpan(
                  text: searchQuery,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF001858),
                  ),
                ),
                const TextSpan(text: '"'),
              ],
            ),
          ),
        ),
        
        // Results grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final project = searchResults[index];
                return ProjectCard(
                  project: project,
                  onTap: () => onProjectTap(project),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
