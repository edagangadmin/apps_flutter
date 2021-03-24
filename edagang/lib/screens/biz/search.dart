import 'package:cached_network_image/cached_network_image.dart';
import 'package:edagang/models/search_model.dart';
import 'package:edagang/screens/biz/biz_company_detail.dart';
import 'package:edagang/utils/constant.dart';
import 'package:edagang/utils/shared_prefs.dart';
import 'package:edagang/widgets/html2text.dart';
import 'package:edagang/widgets/page_slide_right.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert' show json, utf8;
import 'dart:io';

import 'package:google_fonts/google_fonts.dart';


class SearchList extends StatefulWidget {
  SearchList({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SearchState();
}

class _SearchState extends State<SearchList> {
  final key = GlobalKey<ScaffoldState>();
  final TextEditingController _searchQuery = TextEditingController();
  bool _isSearching = false;
  String _error;
  List<Repo> _results = List();

  Timer debounceTimer;

  _SearchState() {
    _searchQuery.addListener(() {
      if (debounceTimer != null) {
        debounceTimer.cancel();
      }
      debounceTimer = Timer(Duration(milliseconds: 500), () {
        if (this.mounted) {
          //debounceTimer.cancel();
          performSearch(_searchQuery.text);
        }
      });
    });
  }

  void performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _error = null;
        _results = List();
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _error = null;
      _results = List();
    });

    final repos = await Api.getRepositoriesWithSearchQuery(query);
    if (this._searchQuery.text == query && this.mounted) {
      setState(() {
        _isSearching = false;
        if (repos != null) {
          _results = repos;
        } else {
          _error = 'Error searching repos';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: key,
        appBar: AppBar(
          backgroundColor: Color(0xffEEEEEE),
          centerTitle: true,
          title: Container(
            height: 37,
            decoration: BoxDecoration(
              //border: Border.all(width: 1, color: Color(0xff2877EA),),
              borderRadius: BorderRadius.all(Radius.circular(25)),
              color: Colors.white,
            ),
            child: SizedBox(
              height: 37,
              child: TextField(
                autofocus: true,
                controller:_searchQuery,
                style: GoogleFonts.lato(
                  textStyle: TextStyle(color: Colors.grey.shade700, fontSize: 16, fontWeight: FontWeight.w500,),
                ),
                cursorColor: Color(0xff2877EA),
                decoration: InputDecoration(
                  border: new UnderlineInputBorder(
                    borderSide: new BorderSide(color: Color(0xff084B8C))
                  ),
                  suffixIcon: Padding(
                    padding: EdgeInsetsDirectional.only(end: 10.0),
                    child: Icon(
                      CupertinoIcons.search,
                      color: Color(0xff084B8C),
                    )
                  ),
                  hintText: "Search ...",
                  hintStyle: TextStyle(color: Colors.grey.shade500)
                ),
              )
            ),
          ),
          flexibleSpace: Container(
              decoration: BoxDecoration(
                color: Colors.white
                /*gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.topRight,
                    colors: [
                      Color(0xff2877EA),
                      Color(0xffA0CCE8),
                    ]
                ),*/
              )
          ),
        ),
        body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    if (_isSearching) {
      return CenterTitleProgress('Searching smartbiz...');
    } else if (_error != null) {
      return CenterTitle(_error);
    } else if (_searchQuery.text.isEmpty) {
      return CenterTitle('');
    } else if (_results.length > 0) {
      return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 5.0),
          itemCount: _results.length,
          itemBuilder: (BuildContext context, int index) {
            return SmartbizItem(_results[index]);
          }
      );
    } else {
      return CenterTitle('No result found.');
    }
  }

}

class CenterTitle extends StatelessWidget {
  final String title;

  CenterTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        alignment: Alignment.center,
        child: Text(
          title,
          style: Theme.of(context).textTheme.subtitle1,
          textAlign: TextAlign.center,
        ));
  }
}

class CenterTitleProgress extends StatelessWidget {
  final String title;

  CenterTitleProgress(this.title);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xff2877EA)),
                strokeWidth: 1.5
            ),
            SizedBox(height: 16,),
            Text(
              title,
              style: Theme.of(context).textTheme.subtitle1,
              textAlign: TextAlign.center,
            )
          ],
        ));
  }
}

class SmartbizItem extends StatelessWidget {
  final Repo repo;
  SmartbizItem(this.repo);
  SharedPref sharedPref = SharedPref();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
          onTap: () {
            sharedPref.save("biz_id", repo.bizId.toString());
            Navigator.push(context, SlideRightRoute(page: BizCompanyDetailPage(repo.bizId.toString(),repo.company)));
          },
          highlightColor: Colors.lightBlueAccent,
          splashColor: Colors.red,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text((repo.company != null) ? repo.company : '-',
                      style: GoogleFonts.lato(
                        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,),
                      ),
                  ),
                  Text((repo.prodName != null) ? repo.prodName : '-',
                      style: GoogleFonts.lato(
                        textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,),
                      ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 4.0),
                    child: repo.prodDesc != null
                        ? htmlText(repo.prodDesc)
                        : Text('No desription'),
                  ),
                ]),
          )),
    );
  }

}

class Api {
  static final HttpClient _httpClient = HttpClient();
  static final String _url = "bizapp.e-dagang.asia";

  static Future<List<Repo>> getRepositoriesWithSearchQuery(String query) async {
    final uri = Uri.https(_url, '/api/product/search', {
      'search_text': query,
    });

    final jsonResponse = await _getJson(uri);
    if (jsonResponse == null) {
      return null;
    }
    if (jsonResponse['errors'] != null) {
      return null;
    }
    if (jsonResponse['data']['product'] == null) {
      return List();
    }

    return Repo.mapJSONStringToList(jsonResponse['data']['product']);
  }

  static Future<Map<String, dynamic>> _getJson(Uri uri) async {
    try {
      //final httpRequest = await _httpClient.postUrl(uri);
      //httpRequest.headers.set(HttpHeaders.authorizationHeader, "Bearer "+Constants.tokenGuest);
      //httpRequest.headers.set(HttpHeaders.contentTypeHeader, "application/json; charset=UTF-8");

      HttpClientRequest request = await _httpClient.postUrl(uri);
      request.headers.set(HttpHeaders.authorizationHeader, "Bearer "+Constants.tokenGuest);

      final httpResponse = await request.close();
      print('HTTPCLIENT RESPONSE CODE >>>>>>> '+httpResponse.statusCode.toString());
      if (httpResponse.statusCode != HttpStatus.OK) {
        return null;
      }

      final responseBody = await httpResponse.transform(utf8.decoder).join();
      print('HTTPCLIENT RESPONSE DATA ======= '+responseBody.toString());
      return json.decode(responseBody);
    } on Exception catch (e) {
      print('$e');
      return null;
    }
  }
}