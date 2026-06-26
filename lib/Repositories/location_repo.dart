import 'package:sqflite/sqflite.dart';
import 'package:wonder_poll/Model/location.dart';

class LocationRepo {
  // Cached database singleton instance to prevent connection leaks
  static Database? _database;

  static Future<Database> _getDatabase() async {
    // If the database is already open, reuse it directly
    if (_database != null) return _database!;

    _database = await openDatabase(
      'location-manager.db',
      version: 2,
      onUpgrade: (db, oldVersion, newVersion) async {
        // Fixed: Conditional check prevents crashing if column already exists
        if (oldVersion < 2) {
          await db.execute("ALTER TABLE locations ADD COLUMN imagePath TEXT");
        }
      },
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE locations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            address TEXT, 
            description TEXT,
            imagePath TEXT
          )
        ''');

        // Note: Ensure your UI treats these specific strings as asset images,
        // or copy assets to the application directory before seeding here.
        await db.insert('locations', {
          'name': "Binondo", 
          'address': 'Binondo, Manila', 
          'description': "Manila's Chinatown",
          'imagePath': "assets/images/binondo.jpg" 
        });
        await db.insert('locations', {
          'name': "Intramuros", 
          'address': 'Intramuros, Manila', 
          'description': "Manila's walled city",
          'imagePath': "assets/images/intra.png"
        });
      },
    );
    
    return _database!;
  }

  static Future<List<Location>> getLocation() async {
    final db = await _getDatabase();
    final List<Map<String, dynamic>> result = await db.query('locations');
    return result.map((json) => Location.fromMap(json)).toList();
  }

  static Future<int> addLocation(Location location) async {
    final db = await _getDatabase();
    // Exclude the ID when inserting so SQLite autoincrement takes over naturally
    final data = location.toMap();
    if (location.id == null) {
      data.remove('id'); 
    }
    return await db.insert('locations', data);
  }

  static Future<int> updateLocation(Location location) async {
    // Prevent updating if the ID is missing
    if (location.id == null) return 0; 
    
    final db = await _getDatabase();
    return await db.update(
      'locations', 
      location.toMap(),
      where: 'id = ?',
      whereArgs: [location.id],
    );
  }

  static Future<int> deleteLocation(int id) async {
    final db = await _getDatabase();
    return await db.delete(
      'locations', 
      where: 'id = ?', 
      whereArgs: [id],
    );
  }
}
