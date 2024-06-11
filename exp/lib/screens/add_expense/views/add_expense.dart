import "package:exp/screens/add_expense/blocs/create_expense_bloc/create_expense_bloc.dart";
import "package:exp/screens/add_expense/blocs/get_categories_bloc/get_categories_bloc.dart";
import "package:exp/screens/add_expense/views/category_creation.dart";
import "package:expense_repository/expense_repository.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:intl/intl.dart";
import "package:uuid/uuid.dart";

class AddExpense extends StatefulWidget {
  const AddExpense({super.key});

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  TextEditingController expenseController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  //DateTime selectDate = DateTime.now();
  late Expense expense;
  bool isLoading = false;

  List<String> myCategoriesIcon = [
    "entertainment",
    "food",
    "home",
    "pet",
    "shopping",
    "tech",
    "travel",
  ];

  @override
  void initState() {
    dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    expense = Expense.empty;
    expense.expenseId = const Uuid().v1();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateExpenseBloc, CreateExpenseState>(
      listener: (context, state) {
        if (state is CreateExpenseSuccess) {
          Navigator.pop(context, expense);
        } else if (state is CreateExpenseLoading) {
          setState(() {
            isLoading = true;
          });
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Colors.grey[800],
          appBar: AppBar(
            backgroundColor: Colors.yellow[800],
            title: Text(
              "Add Expense",
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.grey[800]),
            ),
            centerTitle: true,
          ),
          body: BlocBuilder<GetCategoriesBloc, GetCategoriesState>(
            builder: (context, state) {
              if (state is GetCategoriesSuccess) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 16,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: TextFormField(
                          controller: expenseController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[900],
                            prefixIcon: Icon(
                              CupertinoIcons.money_dollar,
                              color: Colors.yellow[800],
                              size: 24,
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 32,
                      ),
                      TextFormField(
                        readOnly: true,
                        onTap: () {},
                        controller: categoryController,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: expense.category == Category.empty
                              ? Colors.grey[900]
                              : Color(expense.category.color),
                          prefixIcon: expense.category == Category.empty 
                              ? Icon(
                                  CupertinoIcons.list_bullet,
                                  color: Colors.yellow[800],
                                  size: 24,
                                )
                              : Image.asset(
                                  'images/${expense.category.icon}.png',
                                  scale: 2,
                                ),
                          suffixIcon: IconButton(
                              onPressed: () async {
                                var newCategory =
                                    await getCategoryCreation(context);
                                print(newCategory);
                                setState(() {
                                  state.categories.insert(0, newCategory);
                                });
                              },
                              icon: expense.category == Category.empty 
                                ? Icon(
                                    CupertinoIcons.plus_circle_fill,
                                    color: Colors.yellow[800],
                                    size: 24,)
                                  
                                : Icon(
                                    CupertinoIcons.plus_circle_fill,
                                    color: Colors.black,
                                    size: 24,)),

                          hintText: "Category",
                          hintStyle: TextStyle(color: Colors.grey[700]),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(12)),
                              borderSide: BorderSide.none),
                        ),
                      ),
                      Container(
                        height: 200,
                        width: MediaQuery.of(context).size.width,
                        decoration: const BoxDecoration(
                          color: Color.fromRGBO(97, 97, 97, 1),
                          borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(12)),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListView.builder(
                                itemCount: state.categories.length,
                                itemBuilder: (context, int i) {
                                  return Card(
                                    child: ListTile(
                                      onTap: () {
                                        setState(() {
                                          expense.category =
                                              state.categories[i];
                                          categoryController.text =
                                              expense.category.name;
                                        });
                                      },
                                      leading: Image.asset(
                                        'images/${state.categories[i].icon}.png',
                                        scale: 2,
                                      ),
                                      title: Text(
                                        state.categories[i].name,
                                      ),
                                      tileColor:
                                          Color(state.categories[i].color),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                  );
                                })),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        controller: dateController,
                        textAlignVertical: TextAlignVertical.center,
                        readOnly: true,
                        onTap: () async {
                          DateTime? newDate = await showDatePicker(
                              context: context,
                              initialDate: expense.date,
                              firstDate: DateTime.now(),
                              lastDate:
                                  DateTime.now().add(Duration(days: 365)));
                          if (newDate != null) {
                            setState(() {
                              dateController.text =
                                  DateFormat('dd/MM/yyyy').format(newDate);
                              //selectDate = newDate;
                              expense.date = newDate;
                            });
                          }
                        },
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[900],
                          prefixIcon: Icon(
                            CupertinoIcons.calendar_badge_plus,
                            color: Colors.yellow[800],
                            size: 24,
                          ),
                          hintText: "Date",
                          hintStyle: TextStyle(color: Colors.grey[700]),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: kToolbarHeight,
                        child: isLoading
                            ? Center(child: CircularProgressIndicator())
                            : TextButton(
                                onPressed: () {
                                  setState(() {
                                    expense.amount =
                                        int.parse(expenseController.text);
                                  });

                                  context
                                      .read<CreateExpenseBloc>()
                                      .add(CreateExpense(expense));
                                },
                                style: TextButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12))),
                                child: Text(
                                  "Save",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                              ),
                      )
                    ],
                  ),
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
