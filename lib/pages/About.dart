import 'package:flutter/material.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222429),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Logo / Header Section
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Placeholder for your App Icon
                  Container(
                    height: 90,
                    width: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFFad2a2a),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.map_outlined, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Wander-Poll',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Version 1.0.0',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // ==========================================
            // EDIT HERE: APPLICATION DESCRIPTION SECTION
            // ==========================================
            const Text(
              'Application Description',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2D34),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Wander-Poll is an interactive social tool designed to help users decide, '
                'and vote on unique locations around them in order to make decision making  '
                "easier for friends and barkadas. Log and record places you've been, and suggest"
                "new areas to explore. All within one app- it's nothing less than wonderful" ,
                style: TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
              ),
            ),
            const SizedBox(height: 32),

            // ==========================================
            // EDIT HERE: CONTRIBUTIONS SECTION
            // ==========================================
            const Text(
              'Contributions & Members',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            // Contributor 1
            _buildContributorCard(
              name: 'Mikaela Capitan',
              role: 'Leader, Conceptualizer',
              contribution: 'Ideated the application concept, targeting areas to solve that are relatable.',
            ),
            const SizedBox(height: 12),

            // Contributor 2
            _buildContributorCard(
              name: 'Jian Alfante',
              role: 'Lead Developer',
              contribution: 'Created the application from scratch, put together the layout and the design from wireframe to prototype.',
            ),
            const SizedBox(height: 12),

            _buildContributorCard(
              name: 'Pamela Castillo',
              role: 'Goal setter',
              contribution: 'Created smart attainable goals for the application and its developers.',
            ),
            const SizedBox(height: 12),

            _buildContributorCard(
              name: 'Sandra Dignos',
              role: 'Solutions executive',
              contribution: 'Formulated solutions for identified problems at the beginning of conceptualization.',
            ),
            const SizedBox(height: 12),

            _buildContributorCard(
              name: 'Anne Nabor',
              role: 'Output visualizer',
              contribution: 'Detailed the expected output for the application and the team of developers.',
            ),
            const SizedBox(height: 12),

            _buildContributorCard(
              name: 'Ishi Velasco',
              role: 'Limitations admin',
              contribution: 'Made sure all ideation, conceptualization, and development is within scope of project goals',
            ),
            const SizedBox(height: 12),

            _buildContributorCard(
              name: 'Arn Mendoza',
              role: 'Technologies expert',
              contribution: 'Listed technologies and tools that were used during project development.',
            ),
            const SizedBox(height: 12),

            _buildContributorCard(
              name: 'Christian Aguinaldo',
              role: 'Problem setter',
              contribution: 'Derived the primary problem or issue that served as the motivation for the creation of the project.',
            ),
            const SizedBox(height: 12),
            
            const SizedBox(height: 40),
            // Footer credits
            const Center(
              child: Text(
                '© 2026 Wander-Poll Team. All rights reserved.',
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper template for contributor items
  Widget _buildContributorCard({
    required String name,
    required String role,
    required String contribution,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D34),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                role,
                style: const TextStyle(color: Color(0xFFad2a2a), fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(color: Colors.white10),
          ),
          Text(
            contribution,
            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }
}