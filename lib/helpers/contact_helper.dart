import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

//nome das colunas na tabela
final String contactTable = "contactTable";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imgColumn = "imgColumn";

//não haverá varias instancias
class ContactHelper {
  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  //construtor
  ContactHelper.internal();
//declarando o banco de dados
  Database _db;

//inicializando o banco
  Future<Database> get db async {
    //se o banco de dados ja foi inicializado, retorna o _db
    if (_db != null) {
      return _db;
    } else {
      //inicializa o banco
      _db = await initDb();
      return _db;
    }
  }

  //criando função initDb
  //inicializando o banco de dados
  Future<Database> initDb() async {
    //pegando o local onde o banco está armazenado
    final databasesPath = await getDatabasesPath();
    //pegando o caminho do arquivo que está armazenado o banco de dados
    final path = join(databasesPath, "contactsnew.db");
    //abrindo o banco
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute(
          "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT,"
          "$phoneColumn TEXT, $imgColumn TEXT)");
    });
  }

  //função para salvar o contato
  Future<Contact> saveContact(Contact contact) async {
    //obtendo o banco de dados
    Database dbContact = await db;
    //
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact;
  }

  //função para ler o contato
  Future<Contact> getContact(int id) async {
    //obtendo o banco de dados
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(contactTable,
        columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
        where: "$idColumn = ?",
        whereArgs: [id]);
    //verificando se retornou o contato
    if (maps.length > 0) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }

  //função para deletar um contato
  Future<int> deleteContact(int id) async {
    //obtendo o banco de dados
    Database dbContact = await db;
    //retorna um numero inteiro indicando se a deleção ocorreu com sucesso
    return await dbContact
        .delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  //função para atualizar um contato
  Future<int> updateContact(Contact contact) async {
    //obtendo o banco de dados
    Database dbContact = await db;

    return await dbContact.update(contactTable, contact.toMap(),
        where: "$idColumn = ?", whereArgs: [contact.id]);
  }

  //obtendo todos os contatos
  Future<List> getAllContacts() async {
    //obtendo o banco de dados
    Database dbContact = await db;
    //lista de contatos
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
    //transformando a lista em contatos
    List<Contact> listContact = List();
    for (Map m in listMap) {
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }

  //função para obter o numero de contattos da lista
  Future<int> getNumber() async {
    //obtendo o banco de dados
    Database dbContact = await db;
    return Sqflite.firstIntValue(
        await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }

  //função para fechar o banco de dados
  Future close() async{
    Database dbContact = await db;
    dbContact.close();

  }

}

//molde
class Contact {
  int id;
  String name;
  String email;
  String phone;
  String img;

  Contact();

//construtor
// pegando o map e transformando em contato
  Contact.fromMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }

//pegando o contato e transformamndo em mapa
  // não é colocado o id pois o banco de dados irá gerar automaticamente
  Map toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img
    };
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Contact(id: $id, name: $name, email: $email, phone: $phone, img: $img)";
  }
}
