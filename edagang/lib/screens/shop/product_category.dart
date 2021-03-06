import 'dart:ui';
import 'package:edagang/scoped/scoped_product.dart';
import 'package:edagang/helper/shared_prefrence_helper.dart';
import 'package:edagang/widgets/product_grid_card.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scoped_model/scoped_model.dart';


class ProductListCategory extends StatefulWidget {
  String catId, catName;
  ProductListCategory(this.catId, this.catName);

  @override
  ProductListCategoryState createState() {
    return new ProductListCategoryState();
  }
}

class ProductListCategoryState extends State<ProductListCategory> {
  BuildContext context;
  ProductScopedModel model;
  int pageIndex = 1;
  SharedPref sharedPref = SharedPref();

  final Color color2 = Colors.grey;
  final Color color1 = Colors.white;
  final Color color3 = Colors.grey.shade300;

  final List<String> _dropdownValues = [
    "Popular",
    "Lowest",
    "Highest"
  ];
  String _currentlySelected = "Popular";

  Widget dropdownWidget() {
    return DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          items: _dropdownValues.map((value) => DropdownMenuItem(
            child: Text(value),
            value: value,
          )).toList(),

          onChanged: (String value) {
            setState(() {
              _currentlySelected = value;
            });
          },
          isExpanded: false,
          value: _currentlySelected,
        )
    );
  }

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics().logEvent(name: 'Cartsini_product_cat',parameters:null);
  }

  @override
  Widget build(BuildContext context) {
    ProductScopedModel productModel = ProductScopedModel();
    productModel.parseCategoryProductsFromResponse(int.parse(widget.catId), 1, _currentlySelected);

    return new ScopedModel<ProductScopedModel>(
      model: productModel,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          title: CategoryName(catId: int.parse(widget.catId)),
          flexibleSpace: Container(
            color: Colors.white,
            /*decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.topRight,
                colors: <Color>[
                  Color(0xffF45432),
                  Colors.deepOrangeAccent.shade100,
                ],
              ),
            ),*/
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 0.0, right: 10),
              child: dropdownWidget(),
            ),
          ],
        ),
        backgroundColor: Colors.grey.shade100,
        body: CustomScrollView(
          slivers: <Widget>[
            SliverPadding(
              padding: EdgeInsets.fromLTRB(8, 5, 8, 10),
              sliver: ProductsListCategoryBody(catId: int.parse(widget.catId), filte: _currentlySelected),
            ),
            /*SliverFillRemaining(
              child: new Container(color: Colors.transparent),
            ),*/
          ]
        )
      ),
    );
  }

}

class CategoryName extends StatelessWidget {
  BuildContext context;
  ProductScopedModel model;
  final int catId;
  Map<dynamic, dynamic> responseBody;
  CategoryName({@required this.catId});

  @override
  Widget build(BuildContext context) {
    this.context = context;

    return ScopedModelDescendant<ProductScopedModel>(
      builder: (context, child, model) {
        this.model = model;
        return _getCatName();
      },
    );
  }

  _getCatName() {
    return Text(model.getCategoryName() ?? '',
      style: GoogleFonts.lato(
        textStyle: TextStyle(fontSize: 17 , fontWeight: FontWeight.w600,),
      ),
    );
  }
}

class ProductsListCategoryBody extends StatelessWidget {
  BuildContext context;
  ProductScopedModel model;
  final int catId;
  final String filte;
  Map<dynamic, dynamic> responseBody;
  ProductsListCategoryBody({@required this.catId, this.filte});
  int pageIndex = 1;

  @override
  Widget build(BuildContext context) {
    this.context = context;

    return ScopedModelDescendant<ProductScopedModel>(
      builder: (context, child, model) {
        this.model = model;
        return _buildListView();
      },
    );
  }

  _buildListView() {
    return MediaQuery.removePadding(
      removeTop: true,
      context: context,
      child: new SliverStaggeredGrid.countBuilder(
        crossAxisCount: 4,
        mainAxisSpacing: 0.5,
        crossAxisSpacing: 0.5,
        itemCount: model.productsList.length,
        itemBuilder: (context, index) =>
          ProductCardItem(
            product: model.productsList[index],
          ),
        staggeredTileBuilder: (index) => StaggeredTile.fit(2),
      ),
    );
  }

}

