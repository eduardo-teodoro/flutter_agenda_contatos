import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:async';



class ContactPage extends StatefulWidget {
  final Contact contact;

  //pagina para abrir ao clicar no contato
  //construtor
  //parametro entre chaves, pois a passagem dele é opcional
  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameFocus = FocusNode();

  bool _userEdited;

  Contact _editedContact;

  @override
  void initState() {
    super.initState();

    //se o contato for nulo, significa que é um contato novo
    //contact que vem da classe acima
    if (widget.contact == null) {
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact.toMap());
      //ao carregar a tela, p-reenche os campos com o registro do db
      _nameController.text = _editedContact.name;
      _emailController.text = _editedContact.email;
      _phoneController.text = _editedContact.phone;
    }
  }

//layout da pagina
  @override
  Widget build(BuildContext context) {
    //pop é a seta superior esquerda exibida
    return WillPopScope(
      onWillPop: _requestPop ,
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.red,
            title: Text(_editedContact.name ?? "Novo Contato"),
            centerTitle: true,
          ),
          //botão flutuante
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (_editedContact.name != null && _editedContact.name.isNotEmpty) {
                //eliminando activity atual
                Navigator.pop(context, _editedContact);
              } else {
                FocusScope.of(context).requestFocus(_nameFocus);
              }
            },
            child: Icon(Icons.save),
            backgroundColor: Colors.red,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                //GestureDetector para ser capaz de clicar na imagem
                GestureDetector(
                  child: Container(
                    width: 140.0,
                    height: 140.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          //verifica se contato salvou a imagem
                          image: _editedContact.img != null ?
                          FileImage(File(_editedContact.img)):
                          AssetImage("images/person.png"),
                          //deixa a imagem de forma circular
                          fit: BoxFit.cover
                      ),
                    ),
                  ),
                  onTap: () {
                    ImagePicker.pickImage(source: ImageSource.camera).then((
                        file) {
                      if (file == null) return;
                      setState(() {
                        _editedContact.img = file.path;
                      });
                    });
                  },
                ),
                TextField(
                  controller: _nameController,
                  focusNode: _nameFocus,
                  decoration: InputDecoration(labelText: "Nome"),
                  onChanged: (text) {
                    _userEdited = true;
                    setState(() {
                      _editedContact.name = text;
                    });
                  },
                ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: "Email"),
                  onChanged: (text) {
                    _userEdited = true;
                    _editedContact.email = text;
                  },
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: "Phone"),
                  onChanged: (text) {
                    _userEdited = true;
                    _editedContact.phone = text;
                  },
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          )
      ),
    );
  }
  Future<bool> _requestPop(){



    //se algum campo foi editado

    if( _userEdited ==true ){
      showDialog(context: context,
      builder: (context){
        return AlertDialog(
          title: Text("Descartar alterações?"),
          content: Text("Se sair sem salvar as alterações serão perdidas"),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancelar"),
              onPressed: (){
                //apresentando tela anterior
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text("Sim"),
              onPressed: (){
                Navigator.pop(context);
                Navigator.pop(context);

              },
            ),
          ],
        );
      }
      );

      return Future.value(false);

    }else{

      return Future.value(true);




    }
  }


}
