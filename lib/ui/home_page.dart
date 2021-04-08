import 'package:app_busca_gifs/ui/gif_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'dart:convert';

import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _key = 'jwVMOV1Fe1lOq64ffZMcIralb1mpFzFi';
  String _busca;
  int _offset = 0;

  Future<Map> _getGifs() async {
    http.Response response;

    if (_busca == null) {
      response = await http.get(
          'https://api.giphy.com/v1/gifs/trending?api_key=$_key&limit=20&rating=G');
    } else {
      response = await http.get(
          'https://api.giphy.com/v1/gifs/search?api_key=$_key&q=$_busca&limit=25&offset=$_offset&rating=G&lang=en');
    }

    return json.decode(response.body);
  }

  int _getCount(List data) {
    if (_busca == null || _busca.isEmpty) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      padding: EdgeInsets.all(10.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 10.0, mainAxisSpacing: 10.0),
      itemCount: _getCount(snapshot.data['data']),
      itemBuilder: (context, index) {
        if (_busca == null || index < snapshot.data['data'].length) {
          return GestureDetector(
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: snapshot.data['data'][index]['images']['fixed_height']
                  ['url'],
              height: 300.0,
              fit: BoxFit.cover,
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          GifPage(snapshot.data['data'][index])));
            },
            onLongPress: () {
              Share.share(snapshot.data['data'][index]['images']['fixed_height']
                  ['url']);
            },
          );
        } else {
          return Container(
            child: GestureDetector(
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 100.0,
                  ),
                  Text(
                    'Carregar mais Gifs...',
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
              onTap: () {
                setState(() {
                  _offset += 19;
                });
              },
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Image.network(
            "https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif"),
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                  labelText: "Digite sua pesquisa",
                  labelStyle: TextStyle(color: Colors.white),
                  focusedBorder: const OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.blue, width: 2.0),
                  ),
                  enabledBorder: const OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.blue, width: 0.0)),
                  border: OutlineInputBorder()),
              style: TextStyle(color: Colors.white, fontSize: 16.0),
              textAlign: TextAlign.left,
              onSubmitted: (text) {
                setState(() {
                  _busca = text;
                  _offset = 0;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getGifs(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200.0,
                      height: 200.0,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 5.0,
                      ),
                    );
                  default:
                    if (snapshot.hasError)
                      return Container();
                    else
                      return _createGifTable(context, snapshot);
                }
              },
            ),
          )
        ],
      ),
    );
  }
}

/*  backgroundColor: Colors.black,
      body: FutureBuilder(
        future: _getGifs(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return Center(
                  child: Container(
                width: 200.0,
                height: 200.0,
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 5.0,
                ),
              ));

            default:
              return _createGifTable(context, snapshot);
          }
        },
      ), */
