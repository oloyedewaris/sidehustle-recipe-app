import 'package:flutter/material.dart';

import 'package:recipe-app/src/models/recipe_model.dart';
import 'package:recipe-app/src/utils/recipes_store.dart';
import 'package:recipe-app/src/ui/widgets/recipes_card.dart';
import 'package:recipe-app/src/models/recipe_state.dart';
import 'package:recipe-app/src/state_widget.dart';
import 'package:recipe-app/src/ui/screens/recipes_login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe-app/src/ui/widgets/settings_btn.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  StateModel appState;
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildContent() {
    if (appState.isLoading) {
      return Scaffold(
        body: _buildLoadingIndicator(),
      );
    } else if (!appState.isLoading && appState.user == null) {
      return new LoginScreen();
    } else {
      List<Widget> _widgetOptions = <Widget>[
        _buildRecipes(recipeType: RecipeType.food),
        _buildRecipes(recipeType: RecipeType.drink),
        _buildRecipes(ids: appState.favorites),
        _buildSettings(),
      ];

      return Scaffold(
        appBar: AppBar(
          title: Text("Km Recipes",
              style: TextStyle(fontSize: 30, color: Colors.orange)),
        ),
        body: _widgetOptions.elementAt(_selectedIndex),
        floatingActionButton: Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context)
                .colorScheme
                .copyWith(secondary: Colors.orange),
          ),
          child: FloatingActionButton(
            onPressed: () => Navigator.of(context).pushNamed('/add_recipe'),
            child: Icon(Icons.add),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.restaurant,
                  color: Colors.grey,
                ),
                title: Text("Food")),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.local_drink,
                  color: Colors.grey,
                ),
                title: Text('Drink')),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.favorite,
                  color: Colors.grey,
                ),
                title: Text('Favorites')),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.settings,
                  color: Colors.grey,
                ),
                title: Text('Settings'))
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      );
    }
  }

  Center _buildLoadingIndicator() {
    return Center(
      child: new CircularProgressIndicator(),
    );
  }

  Padding _buildRecipes({RecipeType recipeType, List<String> ids}) {
    CollectionReference collectionReference =
        Firestore.instance.collection('recipes');
    Stream<QuerySnapshot> stream;
    // The argument recipeType is set
    if (recipeType != null) {
      stream = collectionReference
          .where("type", isEqualTo: recipeType.index)
          .snapshots();
    } else {
      // Use snapshots of all recipes if recipeType has not been passed
      stream = collectionReference.snapshots();
    }

    // Define query depeneding on passed args
    return Padding(
      // Padding before and after the list view:
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        children: <Widget>[
          Expanded(
            child: new StreamBuilder(
              stream: stream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return _buildLoadingIndicator();
                return new ListView(
                  children: snapshot.data.documents
                      // Check if the argument ids contains document ID if ids has been passed:
                      .where((d) => ids == null || ids.contains(d.documentID))
                      .map((document) {
                    return new RecipeCard(
                      recipe:
                          Recipe.fromMap(document.data, document.documentID),
                      inFavorites:
                          appState.favorites.contains(document.documentID),
                      onFavoriteButtonPressed: _handleFavoritesListChanged,
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Column _buildSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SettingsButton(
          Icons.exit_to_app,
          "Log out",
          appState.user.displayName,
          () async {
            await StateWidget.of(context).signOutOfGoogle();
          },
        ),
      ],
    );
  }

  TabBarView _buildTabsContent() {
    Padding _buildRecipes({RecipeType recipeType, List<String> ids}) {
      CollectionReference collectionReference =
          Firestore.instance.collection('recipes');
      Stream<QuerySnapshot> stream;
      // The argument recipeType is set
      if (recipeType != null) {
        stream = collectionReference
            .where("type", isEqualTo: recipeType.index)
            .snapshots();
      } else {
        // Use snapshots of all recipes if recipeType has not been passed
        stream = collectionReference.snapshots();
      }

      // Define query depeneding on passed args
      return Padding(
        // Padding before and after the list view:
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: new StreamBuilder(
                stream: stream,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) return _buildLoadingIndicator();
                  return new ListView(
                    children: snapshot.data.documents
                        // Check if the argument ids contains document ID if ids has been passed:
                        .where((d) => ids == null || ids.contains(d.documentID))
                        .map((document) {
                      return new RecipeCard(
                        recipe:
                            Recipe.fromMap(document.data, document.documentID),
                        inFavorites:
                            appState.favorites.contains(document.documentID),
                        onFavoriteButtonPressed: _handleFavoritesListChanged,
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    Column _buildSettings() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SettingsButton(
            Icons.exit_to_app,
            "Log out",
            appState.user.displayName,
            () async {
              await StateWidget.of(context).signOutOfGoogle();
            },
          ),
        ],
      );
    }

    return TabBarView(
      children: [
        _buildRecipes(recipeType: RecipeType.food),
        _buildRecipes(recipeType: RecipeType.drink),
        _buildRecipes(ids: appState.favorites),
        _buildSettings(),
      ],
    );
  }

  // Inactive widgets are going to call this method to
  // signalize the parent widget HomeScreen to refresh the list view:
  void _handleFavoritesListChanged(String recipeID) {
    updateFavorites(appState.user.uid, recipeID).then((result) {
      // Update the state:
      if (result == true) {
        setState(() {
          if (!appState.favorites.contains(recipeID))
            appState.favorites.add(recipeID);
          else
            appState.favorites.remove(recipeID);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Build the content depending on the state:
    appState = StateWidget.of(context).state;
    return _buildContent();
  }
}
