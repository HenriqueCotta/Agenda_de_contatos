import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:agenda_de_contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

enum OrderOptions { orderaz, orderza }

class ContactPage extends StatefulWidget {
  final Contact? contact;

  const ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  ContactHelper helper = ContactHelper();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameFocus = FocusNode();

  List<Contact> contacts = [];

  bool _userEdited = false;

  Contact? _editedContact;

  @override
  void initState() {
    super.initState();

    if (widget.contact == null) {
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact!.toMap());

      _nameController.text = _editedContact!.name!;
      _emailController.text = _editedContact!.email!;
      _phoneController.text = _editedContact!.phone!;
    }
    helper.getAllcontacts().then((list) => setState(() {
          contacts = list;
          print(list);
        }));
  }

  @override
  Widget build(BuildContext context) {
    var n = _editedContact?.name;
    return WillPopScope(
      onWillPop: () {
        return _requestPop();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(n == null || n == '' ? "New Contact" : n),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_editedContact?.name != null &&
                _editedContact!.name!.isNotEmpty) {
              Navigator.pop(context, _editedContact);
            } else {
              FocusScope.of(context).requestFocus(_nameFocus);
            }
          },
          child: Icon(Icons.save),
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  final ImagePicker _picker = ImagePicker();
                  final XFile? photo =
                      await _picker.pickImage(source: ImageSource.camera);
                  if (photo == null) return;
                  setState(() {
                    _editedContact!.img = photo.path;
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  width: 140.0,
                  height: 140.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(image: verifyImage()),
                  ),
                ),
              ),
              TextField(
                controller: _nameController,
                focusNode: _nameFocus,
                decoration: InputDecoration(labelText: "Name"),
                onChanged: (textName) {
                  setState(() {
                    _editedContact!.name = textName;
                    _userEdited = true;
                  });
                },
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "email"),
                onChanged: (textEmail) {
                  _editedContact!.email = textEmail;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: "Phone"),
                onChanged: (textPhone) {
                  _editedContact!.phone = textPhone;
                },
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _requestPop() {
    if (_userEdited) {
      showDialog(
          context: context,
          builder: (contex) {
            return AlertDialog(
              title: Text("Discard Alterations?"),
              content: Text("If so, your progress will be lost!"),
              actions: [
                TextButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text("Discard"),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  ImageProvider verifyImage() {
    if (_editedContact?.img != null) {
      return FileImage(File(_editedContact!.img!));
    } else {
      return AssetImage("images/randomUser.png");
    }
  }
}
