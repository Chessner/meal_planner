import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:meal_planner/data/meal_ingredient.dart';
import 'package:meal_planner/database/meal_planner_database_provider.dart';
import 'package:meal_planner/toast.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import '../data/ingredient.dart';
import '../data/meal.dart';
import '../data/tuple.dart';
import '../models/focus_model.dart';
import 'form_text_input_card.dart';

class MealForm extends StatefulWidget {
  const MealForm({this.givenMeal, this.givenIngredientsAmount})
      : assert(
            (givenMeal != null && givenIngredientsAmount != null) ||
                (givenMeal == null && givenIngredientsAmount == null),
            "Either all or no givenX parameters have to be provided");
  final Meal? givenMeal;
  final List<Tuple<Ingredient, num>>? givenIngredientsAmount;

  @override
  State<MealForm> createState() => _MealFormState();
}

class _MealFormState extends State<MealForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _mealNameController = TextEditingController();
  final QuillController _quillController = QuillController.basic();
  final GlobalKey _quillKey = GlobalKey();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  bool _isSubmitting = false;
  bool _setGivens = false;

  // form data
  String _mealName = "";
  List<Tuple<Ingredient, num>> _selectedIngredientsAndAmount = [];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(
      () {
        if (_focusNode.hasFocus) {
          Future.delayed(
            const Duration(milliseconds: 400),
            () {
              Scrollable.ensureVisible(_quillKey.currentContext!,
                  alignmentPolicy:
                      ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
                  curve: Curves.easeInOut,
                  duration: const Duration(milliseconds: 400));
            },
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<Meal?> _onSubmit() async {
    if (_formKey.currentState == null) {
      MealPlannerToast.showLongToast("Something went wrong with the form");
      return null;
    }
    setState(() {
      _isSubmitting = true;
    });
    final formState = _formKey.currentState!;
    if (formState.validate()) {
      formState.save();

      Database database =
          await Provider.of<MealPlannerDatabaseProvider>(context, listen: false)
              .databaseHelper
              .database;
      if (!_setGivens) {
        // Add
        Meal dbMeal = await MealDao(database)
            .insertAndReturnMeal(Meal.create(name: _mealName));

        final List<MealIngredient> mealIngredients =
            _selectedIngredientsAndAmount.map((ingredientAndAmount) {
          return MealIngredient(
              ingredientId: ingredientAndAmount.item1.id!,
              mealId: dbMeal.id!,
              amount: ingredientAndAmount.item2);
        }).toList();
        await MealIngredientDao(database)
            .insertMealIngredients(mealIngredients);
        setState(() {
          _isSubmitting = false;
        });
        return dbMeal;
      } else {
        //Edit
        Meal meal = widget.givenMeal!;
        Meal newMeal = meal.copyWith(newName: _mealName);
        MealDao(database).updateMeal(newMeal);

        final MealIngredientDao mealIngredientDao = MealIngredientDao(database);
        mealIngredientDao.deleteMealIngredientsOfMeal(meal.id!);
        final List<MealIngredient> mealIngredients =
            _selectedIngredientsAndAmount.map((ingredientAndAmount) {
          return MealIngredient(
              ingredientId: ingredientAndAmount.item1.id!,
              mealId: meal.id!,
              amount: ingredientAndAmount.item2);
        }).toList();
        mealIngredientDao.insertMealIngredients(mealIngredients);
        return newMeal;
      }
    }
    setState(() {
      _isSubmitting = false;
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.givenMeal != null && _setGivens == false) {
      _mealNameController.text = widget.givenMeal?.name ?? "";
      _selectedIngredientsAndAmount = widget.givenIngredientsAmount ?? [];
      _setGivens = true;
    }
    return ChangeNotifierProvider(
      create: (context) => FocusModel(),
      child: Scaffold(
        body: Form(
          key: _formKey,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(25),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            8,
                            0,
                            8,
                            0,
                          ),
                          child: Text(
                            widget.givenMeal != null ? "Edit meal" : "Add meal",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Consumer<FocusModel>(
                          builder: (BuildContext context, FocusModel focusModel,
                              Widget? child) {
                            return FormTextInputCard(
                              focusNode: focusModel.titleFNode,
                              validator: (String? content) {
                                if (content == null || content.isEmpty) {
                                  return 'Meal name cannot be empty';
                                }
                                return null;
                              },
                              onSaved: (name) {
                                _mealName = name ?? "";
                              },
                              title: "Name",
                              controller: _mealNameController,
                            );
                          },
                        ),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: QuillProvider(
                              configurations: QuillConfigurations(
                                controller: _quillController,
                              ),
                              child: Column(
                                children: [
                                  const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text("Instructions")),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  const QuillToolbar(
                                      configurations:
                                          QuillToolbarConfigurations(
                                              multiRowsDisplay: false)),
                                  const Divider(),
                                  Container(
                                    key: _quillKey,
                                    child: Consumer<FocusModel>(
                                      builder: (BuildContext context,
                                          FocusModel focusModel,
                                          Widget? child) {
                                        return GestureDetector(
                                          onTap: () {
                                            focusModel.unfocusAll();
                                            _focusNode.requestFocus();
                                          },
                                          child: QuillEditor.basic(
                                            focusNode: _focusNode,
                                            configurations:
                                                const QuillEditorConfigurations(
                                              minHeight: 200,
                                              maxHeight: 200,
                                              readOnly: false,
                                              scrollable: true,
                                              placeholder:
                                                  "Add some instructions here...!",
                                              expands: false,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Consumer2<MealPlannerDatabaseProvider, FocusModel>(
                          builder: (BuildContext context, db, focusModel,
                              Widget? child) {
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: DropdownSearch<Ingredient>(
                                  dropdownDecoratorProps:
                                      const DropDownDecoratorProps(
                                    dropdownSearchDecoration: InputDecoration(
                                        hintText:
                                            "Search for and add ingredients!"),
                                  ),
                                  onBeforeChange:
                                      (oldIngredient, newIngredient) async {
                                    focusModel.add();
                                    setState(() {
                                      _selectedIngredientsAndAmount
                                          .add(Tuple(newIngredient!, 0));
                                    });
                                    return false;
                                  },
                                  popupProps: PopupProps.modalBottomSheet(
                                    emptyBuilder: (context, filterString) {
                                      return const ListTile(
                                        title: Text("No ingredients found!"),
                                      );
                                    },
                                    searchFieldProps: const TextFieldProps(
                                      decoration: InputDecoration(
                                          hintText:
                                              "Search for and add ingredients!"),
                                    ),
                                    showSearchBox: true,
                                    searchDelay: Duration.zero,
                                  ),
                                  enabled: true,
                                  clearButtonProps: const ClearButtonProps(
                                    isVisible: true,
                                    icon: Icon(Icons.cancel_outlined),
                                  ),
                                  filterFn: (ingredient, filter) {
                                    return ingredient.name.contains(filter);
                                  },
                                  asyncItems: (filterString) async {
                                    List<Ingredient> ingredients =
                                        await IngredientDao(await db
                                                .databaseHelper.database)
                                            .getAllIngredients();
                                    return ingredients.where((ingredient) {
                                      return ingredient.name
                                              .contains(filterString) &&
                                          !_selectedIngredientsAndAmount.any(
                                              (element) =>
                                                  element.item1.id ==
                                                  ingredient.id);
                                    }).toList();
                                  },
                                  compareFn: (ingredient1, ingredient2) {
                                    return ingredient1.id! == ingredient2.id!;
                                  },
                                  itemAsString: (ingredient) {
                                    return ingredient.name;
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                        Consumer<FocusModel>(
                          builder:
                              (BuildContext context, FocusModel focusModel, _) {
                            return IngredientAmountList(
                              selectedIngredientsAndAmount:
                                  _selectedIngredientsAndAmount,
                              deleteEntry: (index) {
                                focusModel.remove(index);
                                setState(() {
                                  _selectedIngredientsAndAmount.removeAt(index);
                                });
                              },
                            );
                          },
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).viewInsets.bottom > 60
                              ? MediaQuery.of(context).viewInsets.bottom
                              : 60,
                        )
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ButtonBar(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          child: const Text("Close"),
                        ),
                        _isSubmitting
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: () async {
                                  Meal? meal = await _onSubmit();
                                  if (meal == null) {
                                    MealPlannerToast.showLongToast(
                                        "Please check the form and make sure everything is filled out correctly");
                                  } else {
                                    if (context.mounted) {
                                      Navigator.of(context)
                                          .pop(meal); // Close the dialog
                                    }
                                  }
                                },
                                child: Text(
                                    widget.givenMeal != null ? "Save" : "Add"),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class IngredientAmountList extends StatelessWidget {
  const IngredientAmountList({
    super.key,
    required List<Tuple<Ingredient, num>> selectedIngredientsAndAmount,
    required this.deleteEntry,
  }) : _selectedIngredientsAndAmount = selectedIngredientsAndAmount;

  final List<Tuple<Ingredient, num>> _selectedIngredientsAndAmount;
  final Function(int) deleteEntry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _selectedIngredientsAndAmount.isEmpty
            ? Row(
                children: [
                  Text(
                    "No ingredients added!",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              )
            : ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return Dismissible(
                    onDismissed: (_) {
                      deleteEntry(index);
                    },
                    direction: DismissDirection.startToEnd,
                    background: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Container(
                        color: Colors.red,
                        child: const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.delete),
                          ),
                        ),
                      ),
                    ),
                    key: Key(
                        _selectedIngredientsAndAmount[index].item1.toString()),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            _selectedIngredientsAndAmount[index].item1.name,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              0,
                              0,
                              8,
                              0,
                            ),
                            child: Consumer<FocusModel>(
                              builder: (BuildContext context,
                                  FocusModel focusModel, Widget? child) {
                                return AmountInputField(
                                  focusNode: focusModel.get(index),
                                  initialValue:
                                      _selectedIngredientsAndAmount[index]
                                          .item2,
                                  suffix: Ingredient.suffixOf(
                                      _selectedIngredientsAndAmount[index]
                                          .item1
                                          .unit),
                                  onSaved: (String? amount) {
                                    _selectedIngredientsAndAmount[index].item2 =
                                        double.parse(amount!);
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                itemCount: _selectedIngredientsAndAmount.length,
              ),
      ),
    );
  }
}

class AmountInputField extends StatefulWidget {
  const AmountInputField({
    super.key,
    this.title,
    this.suffix,
    this.onSaved,
    this.initialValue,
    this.leading,
    this.focusNode,
  });

  final Widget? leading;
  final String? title;
  final String? suffix;
  final void Function(String?)? onSaved;
  final num? initialValue;
  final FocusNode? focusNode;

  @override
  State<AmountInputField> createState() => _AmountInputFieldState();
}

class _AmountInputFieldState extends State<AmountInputField> {
  GlobalKey _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.title != null ? Text(widget.title!) : Container(),
        Row(
          children: [
            Container(
              child: widget.leading,
            ),
            Expanded(
              flex: 3,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    focusNode: widget.focusNode,
                    key: _globalKey,
                    //scrollPadding: EdgeInsets.only(
                    //    bottom: MediaQuery.of(context).viewInsets.bottom + 12),
                    onTap: () async {
                      await Future.delayed(const Duration(milliseconds: 400));
                      Scrollable.ensureVisible(
                        _globalKey.currentContext!,
                        alignment: 0.3,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    },
                    decoration: InputDecoration(
                      errorMaxLines: 4,
                      suffixText: widget.suffix ?? "",
                    ),
                    initialValue: widget.initialValue != null
                        ? widget.initialValue.toString()
                        : "0",
                    onSaved: widget.onSaved,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter a number.";
                      }
                      if (double.tryParse(value.replaceAll(",", ".")) == null) {
                        return "Please enter a valid number.";
                      }
                      if (value == "0" || value == "0." || value == "0,") {
                        return "Amount cannot be 0.";
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
