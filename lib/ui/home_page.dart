import 'dart:io';

import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'contact_page.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions { orderaz, orderza }

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //obtendo o contact helper

  ContactHelper helper = ContactHelper();
  List<Contact> contacts = List();

  //assim que o App inicia irá carregar todos os contatos salvos

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getAllContacts();
  }

/*
  //testando o banco de dados
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Contact c = Contact();
    c.name = "Eduardo Teodoro";
    c.email = "eduardo@gmail.com";
    c.phone = "123456789";
    c.img = "imgTeste";
    helper.saveContact(c);
    //obtendo todos os contatos
    //como retorna um futuro, ou retornamos await ou then
    helper.getAllContacts().then((list) => {
      print (list)});
  }
*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //nome na app bar
        title: Text("Contatos"),
        //cor da app bar
        backgroundColor: Colors.red,
        //centralizando titulo
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordernar de A-Z"),
                value: OrderOptions.orderaz,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordernar de Z-A"),
                value: OrderOptions.orderza,
              ),
            ],
            onSelected: _orderList,
          )
        ],
      ),
      backgroundColor: Colors.white,
      //botão flutuante +
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
          padding: EdgeInsets.all(10.0),
          //tamanho da lista
          itemCount: contacts.length,
          //função que retornara o item da posição
          itemBuilder: (context, index) {
            return _contactCard(context, index);
          }),
    );
  }

  //função para retornar o card de cada contato
  //o index é para indicr qual contato
  Widget _contactCard(BuildContext context, int index) {
    // retorna Gesture detector para ter a opção de clicar nele
    return GestureDetector(
      child: Card(
        //margim nas laterais do card
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              //para colocar a imagem redonda
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      //verifica se contato salvou a imagem
                      image: contacts[index].img != null
                          ? FileImage(File(contacts[index].img))
                          : AssetImage("images/person.png"),
                      //deixa a imagem circular
                      fit: BoxFit.cover ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    //caso a informação esteja vazia, é apresentando ""
                    Text(
                      contacts[index].name ?? "",
                      style: TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      contacts[index].email ?? "",
                      style: TextStyle(fontSize: 18.0),
                    ),
                    Text(
                      contacts[index].phone ?? "",
                      style: TextStyle(fontSize: 18.0),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      onTap: () {
        //exibe as opções
        _showOptions(context, index);
        //mostra os dados do contato
        // _showContactPage(contact: contacts[index]);
      },
    );
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            onClosing: () {},
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  //para que o alert seja exibido no minimo de espaço possivel
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                        child: Text("Ligar",
                            style:
                                TextStyle(color: Colors.red, fontSize: 20.0)),
                        onPressed: () {
                          //abre o telefone
                          launch("tel:${contacts[index].phone}");
                          //fecha a janela de opções
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                        child: Text("Editar",
                            style:
                                TextStyle(color: Colors.red, fontSize: 20.0)),
                        onPressed: () {
                          //fecha a janela de opções
                          Navigator.pop(context);
                          //abre a tela de contato
                          _showContactPage(contact: contacts[index]);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                        child: Text("Excluir",
                            style:
                                TextStyle(color: Colors.red, fontSize: 20.0)),
                        onPressed: () {
                          helper.deleteContact(contacts[index].id);
                          setState(() {
                            //removendo contato da lista
                            contacts.removeAt(index);
                            //fecha a janela de opções
                            Navigator.pop(context);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });
  }

  //função para abrir a contact page
  void _showContactPage({Contact contact}) async {
    final recContact = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ContactPage(
                  contact: contact,
                )));
    //se for nulo, o usuário apenas retornou sem salvar ou sem criar um novo contato
    if (recContact != null) {
      //é quando está editando um contato, o contato ja existia e foi editado
      if (contact != null) {
        //atualizando registro
        await helper.updateContact(recContact);
        //atualizando tela

      } else {
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }

  void _getAllContacts() {
    helper.getAllContacts().then((list) {
      setState(() {
        contacts = list;
      });
    });
  }

  //ordernar a lista
  void _orderList(OrderOptions result) {
    switch(result){
      case OrderOptions.orderaz:
        contacts.sort((a,b){
        return  a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        contacts.sort((a,b){
         return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }
    setState(() {

    });
  }
}
