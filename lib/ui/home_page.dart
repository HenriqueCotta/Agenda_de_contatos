import 'dart:io';
import 'package:agenda_de_contatos/helpers/contact_helper.dart';
import 'package:agenda_de_contatos/ui/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();

  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();

    // Contact c = Contact();
    // c.name = "Henrique";
    // c.email = "henriquecotta1@hotmail.com";
    // c.phone = "+55 (85) 997719870";
    // c.img = null;

    // helper.saveContact(c);
    getAllContacts();
  }

  void getAllContacts() {
    helper.getAllcontacts().then((list) => setState(() {
          contacts = list;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: [
            PopupMenuButton<OrderOptions>(
              icon: Icon(Icons.menu, color: Colors.white,),
              itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
                const PopupMenuItem<OrderOptions>(
                  child: Text("Order A-Z"),
                  value: OrderOptions.orderaz,
                ),
                const PopupMenuItem<OrderOptions>(
                  child: Text("Order Z-A"),
                  value: OrderOptions.orderza,
                ),
              ],
              onSelected: _orderList,
            ),
          ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10.0),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return _contactCard(context, index);
        },
      ),
    );
  }

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        _showOptions(context, index);
      },
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: [
              Container(
                width: 80.0,
                height: 80.0,
                //child: getImage(index),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      fit: BoxFit.fill, image: verifyImage(index)
                      // image: (contacts[index].img != null) ?
                      //  (FileImage(File(contacts[index].img!))) :
                      //    (AssetImage("image/randomUser.png")),
                      ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contacts[index].name ?? "",
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      contacts[index].email ?? "",
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                    Text(
                      contacts[index].phone ?? "",
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider verifyImage(index) {
    if (contacts[index].img != null) {
      return FileImage(File(contacts[index].img!));
    } else {
      return AssetImage("images/randomUser.png");
    }
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                      onPressed: () {
                        launch("tel: ${contacts[index].phone}");
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Call",
                        style: TextStyle(color: Colors.red, fontSize: 20.0),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showContactPage(contact: contacts[index]);
                      },
                      child: Text(
                        "Edit",
                        style: TextStyle(color: Colors.red, fontSize: 20.0),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                      onPressed: () {
                        helper.deleteContact(contacts[index].id!);
                        setState(() {
                        contacts.removeAt(index);
                        Navigator.pop(context);   
                        });
                      },
                      child: Text(
                        "Delete",
                        style: TextStyle(color: Colors.red, fontSize: 20.0),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

    void _orderList(OrderOptions result) {
    switch (result) {
      case OrderOptions.orderaz:
        contacts.sort((a, b) {
            return a.name!.toLowerCase().compareTo(b.name!.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        contacts.sort((a, b) {
            return b.name!.toLowerCase().compareTo(a.name!.toLowerCase());
        });
        break;
    }
    setState(() {});
  }

  void _showContactPage({Contact? contact}) async {
    final recContact = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ContactPage(contact: contact)),
    );
    if (recContact != null) {
      if (contact != null) {
        await helper.updateContact(recContact);
      } else {
        await helper.saveContact(recContact);
      }
      getAllContacts();
    }
  }
}
