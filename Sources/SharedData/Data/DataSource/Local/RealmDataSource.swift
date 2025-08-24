import Foundation
import RealmSwift

public class RealmDataSource {
  private var realm: Realm!  // Instance Realm akan diinisialisasi lazily atau di init
  
  public init() {}
  
  public func getRealm() throws -> Realm {
    if Thread.isMainThread {
      return try Realm() // Mengembalikan instance Realm pada main thread
    } else {
      return try Realm() // Mengembalikan instance Realm pada background thread jika diperlukan
    }
  }
  
  public func addOrUpdate<T: Object & Identifiable>(_ object: T) throws {
    let realm = try getRealm()
    try realm.write {
      realm.add(object, update: .modified)
    }
  }
  
  // Menambah atau memperbarui banyak objek
  public func addOrUpdate<T: Object & Identifiable>(_ objects: [T]) throws {
    let realm = try getRealm()
    try realm.write {
      realm.add(objects, update: .modified)
    }
  }
  
  // Mengambil semua objek dari tipe tertentu
  public func fetchAll<T: Object>(_ type: T.Type) throws -> Results<T> {
    let realm = try getRealm()
    return realm.objects(type)
  }
  
  // Mengambil objek berdasarkan primary key
  public func fetchObject<T: Object & Identifiable>(_ type: T.Type, by id: T.ID) throws -> T? {
    let realm = try getRealm()
    return realm.object(ofType: type, forPrimaryKey: id)
  }
  
  // Menghapus objek berdasarkan primary key
  public func delete<T: Object & Identifiable>(_ type: T.Type, by id: T.ID) throws {
    let realm = try getRealm()
    if let objectToDelete = realm.object(ofType: type, forPrimaryKey: id) {
      try realm.write {
        realm.delete(objectToDelete)
      }
    }
  }
  
  // Menghapus semua objek dari tipe tertentu
  public func deleteAll<T: Object>(_ type: T.Type) throws {
    let realm = try getRealm()
    try realm.write {
      realm.delete(realm.objects(type))
    }
  }
}
