import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:flutter_app/my_flow_app_icons.dart' as custicons;

void main() {
//  runApp(new MyApp());
  debugPaintSizeEnabled = false; //         <--- enable visual rendering
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Generated App',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF2196f3),
        accentColor: const Color(0xFF2196f3),
        canvasColor: const Color(0xFFfafafa),
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var _formKey = GlobalKey<FormState>();
  int _clickcounter = 0;
  double _flowrate = 99.9;
  double _flow = 9.0; //not used
  String _strflowrate = '0.00';
  String _strflow = '0.00';
  //bool _startbutton = true;
  final _PHSController = TextEditingController(text: '12000');
  final _PMSController = TextEditingController(text: '15000');
  final _PLSController = TextEditingController(text: '15000');
  final _PHEController = TextEditingController(text: '15000');
  final _PMEController = TextEditingController(text: '15000');
  final _PLEController = TextEditingController(text: '15000');
  final _VHController = TextEditingController(text: '12.1');
  final _VMController = TextEditingController(text: '12.1');
  final _VLController = TextEditingController(text: '12.1');
  final _TAmbFController = TextEditingController(text: '100.0');
  final _DensityKG_CFController = TextEditingController(text: '0.0');
  final _ZController = TextEditingController(text: '1.0');

  final double _ai1 = 0.0588846;
  final double _ai2 = -0.06136111;
  final double _ai3 = -0.002650473;
  final double _ai4 = 0.002731125;
  final double _ai5 = 0.001802374;
  final double _ai6 = -0.001150707;
  final double _ai7 = 0.00009588528;
  final double _ai8 = -0.00000011094;
  final double _ai9 = 0.0000000001264403;

  final double _bi1 = 1.325;
  final double _bi2 = 1.87;
  final double _bi3 = 2.5;
  final double _bi4 = 2.8;
  final double _bi5 = 2.938;
  final double _bi6 = 3.14;
  final double _bi7 = 3.37;
  final double _bi8 = 3.75;
  final double _bi9 = 4.0;

  final double _ci1 = 1.0;
  final double _ci2 = 1.0;
  final double _ci3 = 2.0;
  final double _ci4 = 2.0;
  final double _ci5 = 2.42;
  final double _ci6 = 2.63;
  final double _ci7 = 3.0;
  final double _ci8 = 4.0;
  final double _ci9 = 5.0;

  double _molar_mass = 2.01588; //g per mol
  double _gas_constant = 8.314472; // Joule per mol Kelvin
  double _Liters_CF = 28.3168; //Liters to CubicFeet
  double _PHS_MPA = 0;
  double _PMS_MPA = 0;
  double _PLS_MPA = 0;
  double _PHE_MPA = 0;
  double _PME_MPA = 0;
  double _PLE_MPA = 0;
  double _TAmb_K = 0;
  double _VH_CF = 0;
  double _VM_CF = 0;
  double _VL_CF = 0;

  //*** added
  Timer _timer;
  int _timercounter = 0;
  bool _isrunning = false;
  bool _ispaused = false;
  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timercounter = 0;

    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
            () {
              if (_timercounter >= 1800) {
                //JOB make it 30 minutes max for now
                timer.cancel();
                _isrunning = false;
                _ispaused = false;
              } else {
                _timercounter = _timercounter + 1;
                _doFlowCalc();
                if (_ispaused) {
                  _timercounter = _timercounter - 1;
                } else {}
              }
            },
          ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

//**** added
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text('Hydrogen Flow Rate'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          autovalidate: true,
          child: Column(
            children: <Widget>[
              Container(
                color: Colors.amber[100],
                width: 400.0,
                height: 250.0,
                child: new Row(
                    //Row 1
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      new Expanded(
                          child: Column(
                              //Column 1
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                            new Expanded(
                                child: new TextFormField(
                              controller: _PHSController,
                              decoration: const InputDecoration(
                                icon: const Icon(Icons.local_parking),
                                hintText: 'H Start',
                                labelText: 'PSIG',
                              ),
                              inputFormatters: [
                                WhitelistingTextInputFormatter.digitsOnly,
                                DecimalTextInputFormatter(decimalRange: 1)
                              ],
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: false, signed: false),
                              validator: validatePressure,
                            ) //End TextFormField
                                ),
                            new Expanded(
                                child: new TextFormField(
                              controller: _PMSController,
                              decoration: const InputDecoration(
                                icon: const Icon(Icons.local_parking),
                                hintText: 'M Start',
                                labelText: 'PSIG',
                              ),
                              inputFormatters: [
                                WhitelistingTextInputFormatter.digitsOnly,
                                DecimalTextInputFormatter(decimalRange: 1)
                              ],
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: false, signed: false),
                              validator: validatePressure,
                            ) //End TextFormField
                                ),
                            new Expanded(
                                child: new TextFormField(
                              controller: _PLSController,
                              decoration: const InputDecoration(
                                icon: const Icon(Icons.local_parking),
                                hintText: 'L Start',
                                labelText: 'PSIG',
                              ),
                              inputFormatters: [
                                WhitelistingTextInputFormatter.digitsOnly,
                                DecimalTextInputFormatter(decimalRange: 1)
                              ],
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: false, signed: false),
                              validator: validatePressure,
                            ) //End TextFormField
                                ),
                            new Expanded(
                                child: new TextFormField(
                              controller: _TAmbFController,
                              decoration: const InputDecoration(
                                icon:
                                    const Icon(custicons.MyFlowApp.temperature),
                                hintText: 'Ambient',
                                labelText: 'F',
                              ),
                              inputFormatters: [
                                WhitelistingTextInputFormatter.digitsOnly,
                                DecimalTextInputFormatter(decimalRange: 1)
                              ],
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: false, signed: false),
                              validator: validateTemperature,
                            ) //End TextFormField
                                ),
                          ])), // End Column 1
                      new Expanded(
                          child: Column(
                              //Column 2
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                            new Expanded(
                                child: new TextFormField(
                              controller: _PHEController,
                              decoration: const InputDecoration(
                                icon: const Icon(Icons.local_parking),
                                hintText: 'H End',
                                labelText: 'PSIG',
                              ),
                              inputFormatters: [
                                WhitelistingTextInputFormatter.digitsOnly,
                                DecimalTextInputFormatter(decimalRange: 1)
                              ],
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: false, signed: false),
                              validator: validatePressure,
                            ) //End TextFormField
                                ),
                            new Expanded(
                                child: new TextFormField(
                              controller: _PMEController,
                              decoration: const InputDecoration(
                                icon: const Icon(Icons.local_parking),
                                hintText: 'M End',
                                labelText: 'PSIG',
                              ),
                              inputFormatters: [
                                WhitelistingTextInputFormatter.digitsOnly,
                                DecimalTextInputFormatter(decimalRange: 1)
                              ],
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: false, signed: false),
                              validator: validatePressure,
                            ) //End TextFormField
                                ),
                            new Expanded(
                                child: new TextFormField(
                              controller: _PLEController,
                              decoration: const InputDecoration(
                                icon: const Icon(Icons.local_parking),
                                hintText: 'L End',
                                labelText: 'PSIG',
                              ),
                              inputFormatters: [
                                WhitelistingTextInputFormatter.digitsOnly,
                                DecimalTextInputFormatter(decimalRange: 1)
                              ],
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: false, signed: false),
                              validator: validatePressure,
                            ) //End TextFormField
                                ),
                            new Expanded(
                                child: new TextFormField(
                              enabled: false,
                              controller: _DensityKG_CFController,
                              decoration: const InputDecoration(
                                icon: const Icon(custicons.MyFlowApp.rho),
                                hintText: 'Density',
                                labelText: 'KG/CF:L@Start',
                              ),
                            ) //End TextFormField
                                ),
                          ])), // end Column 2
                      new Expanded(
                          child: Column(
                              //Column 3
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                            new Expanded(
                                child: new TextFormField(
                              controller: _VHController,
                              decoration: const InputDecoration(
                                icon: const Icon(Icons.brightness_low),
                                hintText: 'High Bank End',
                                labelText: 'WVCF',
                              ),
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: false, signed: false),
                              validator: validateCFWV,
                            ) //End TextFormField
                                ),
                            new Expanded(
                                child: new TextFormField(
                              controller: _VMController,
                              decoration: const InputDecoration(
                                icon: const Icon(Icons.brightness_low),
                                hintText: 'Med Bank End',
                                labelText: 'WVCF',
                              ),
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: false, signed: false),
                              validator: validateCFWV,
                            ) //End TextFormField
                                ),
                            new Expanded(
                                child: new TextFormField(
                              controller: _VLController,
                              decoration: const InputDecoration(
                                icon: const Icon(Icons.brightness_low),
                                hintText: 'Low Bank End',
                                labelText: 'WVCF',
                              ),
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: false, signed: false),
                              validator: validateCFWV,
                            ) //End TextFormField
                                ),
                            new Expanded(
                                child: new TextFormField(
                              enabled: false,
                              controller: _ZController,
                              decoration: const InputDecoration(
                                icon: const Icon(custicons.MyFlowApp.Z),
                                hintText: 'Low @ Start',
                                labelText: 'Z:L@Start',
                              ),
                            ) //End TextFormField
                                ),
                          ])), //End Column 3
                    ]), //end or child row
              ), //Container
              //),//Form

              Row(
                //row for start timer and the time
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  RaisedButton(
                      onPressed: buttonPressedStart,
                      padding: const EdgeInsets.all(8.0),
                      textColor: Colors.white,
                      color: Colors.blue,
                      child: new Text(
                        "Test",
                        style: _ispaused
                            ? TextStyle(color: Colors.red)
                            : TextStyle(color: Colors.black),
                      )),
                  new Text(
                    'Timer(S): ',
                  ),
                  new Text(
                    '$_timercounter',
                    style: Theme.of(context).textTheme.display1,
                  ),
                  RaisedButton(
                    onPressed: buttonPressedReset,
                    padding: const EdgeInsets.all(8.0),
                    textColor: Colors.white,
                    color: Colors.blue,
                    child: new Text("Reset"),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      new Text(
                        'FlowRate(KG/HR):',
                      ),
                      new Text(
                        '$_strflowrate',
                        style: Theme.of(context).textTheme.display1,
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      new Text(
                        'Flow (KG):',
                      ),
                      new Text(
                        '$_strflow',
                        style: Theme.of(context).textTheme.display1,
                      ),
                    ],
                  ), // end column
                ], //end children widget
              ), // end row
              new Text(
                '$_strflowrate',
                //style: Theme.of(context).textTheme.display1,
              ),
              Text("$_clickcounter")
            ],
          ),
        ), //end main column
      ),
    );
    // End Scaffold
  }

  // End Widget Build
  void buttonPressedStart() {
    final form = _formKey.currentState;
    if (form.validate()) {
      // Text forms was validated.
      setState(() {
        _clickcounter++;
        if (!_isrunning) {
          startTimer();
          _isrunning = true;
          _ispaused = false;
        } else {
          _ispaused = !_ispaused;
        }
        ;
      });
    } else {}
  }

  void buttonPressedReset() {
    setState(() {
      _timercounter = 0;
      _clickcounter--; // = 0;
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Reset timer to 0'),
        duration: Duration(seconds: 1),
      ));
    });
  }

  String validateTemperature(String value) {
    if (value.length == 0) {
      return 'empty';
    }
    double isDigitsOnly;
    isDigitsOnly = double.tryParse(value);
    if (isDigitsOnly != null) {
      if (isDigitsOnly < 0 || isDigitsOnly > 400) {
        isDigitsOnly = null;
      }
    }
    return (isDigitsOnly == null ? '0->400F' : null);
  }

  String validateCFWV(String value) {
    if (value.length == 0) {
      return 'empty';
    }
    double isDigitsOnly;
    isDigitsOnly = double.tryParse(value);
    if (isDigitsOnly != null) {
      if (isDigitsOnly < 0 || isDigitsOnly > 1000) {
        isDigitsOnly = null;
      }
    }
    return (isDigitsOnly == null ? '0->1,000 CFWV' : null);
  }

  String validatePressure(String value) {
    if (value.length == 0) {
      return 'empty';
    }
    double isDigitsOnly;
    isDigitsOnly = double.tryParse(value);
    if (isDigitsOnly != null) {
      if (isDigitsOnly < 0 || isDigitsOnly > 15000) {
        isDigitsOnly = null;
      }
    }
    return (isDigitsOnly == null ? '0->15,000 PSIG' : null);
  }

  void _doFlowCalc() {
    double _rollingsum = 0;
    double _ZHS, _ZMS, _ZLS, _ZHE, _ZME, _ZLE, _KGH, _KGM, _KGL, _KGTotal;
    _TAmb_K = ((double.parse(_TAmbFController.text) - 32) * (5 / 9)) +
        273.15; //F to K, F-32x(5/9)+273.15
    _PHS_MPA = double.parse(_PHSController.text) / 145.038; //divide by 145.038
    _PMS_MPA = double.parse(_PMSController.text) / 145.038;
    _PLS_MPA = double.parse(_PLSController.text) / 145.038;
    _PHE_MPA = double.parse(_PHEController.text) / 145.038;
    _PME_MPA = double.parse(_PMEController.text) / 145.038;
    _PLE_MPA = double.parse(_PLEController.text) / 145.038;
    _VH_CF = double.parse(_VHController.text);
    _VM_CF = double.parse(_VMController.text);
    _VL_CF = double.parse(_VLController.text);
    double a, b, c;
    _rollingsum = 1;
    _rollingsum +=
        _ai1 * math.pow((100 / _TAmb_K), _bi1) * math.pow(_PHS_MPA, _ci1);
    a = _ai1;
    b = math.pow((100 / _TAmb_K), _bi1);
    c = math.pow(_PHS_MPA, _ci1);
    _rollingsum +=
        _ai2 * math.pow((100 / _TAmb_K), _bi2) * math.pow(_PHS_MPA, _ci2);
    a = _ai2;
    b = math.pow((100 / _TAmb_K), _bi2);
    c = math.pow(_PHS_MPA, _ci2);
    _rollingsum +=
        _ai3 * math.pow((100 / _TAmb_K), _bi3) * math.pow(_PHS_MPA, _ci3);
    a = _ai3;
    b = math.pow((100 / _TAmb_K), _bi3);
    c = math.pow(_PHS_MPA, _ci3);
    _rollingsum +=
        _ai4 * math.pow((100 / _TAmb_K), _bi4) * math.pow(_PHS_MPA, _ci4);
    a = _ai4;
    b = math.pow((100 / _TAmb_K), _bi4);
    c = math.pow(_PHS_MPA, _ci4);
    _rollingsum +=
        _ai5 * math.pow((100 / _TAmb_K), _bi5) * math.pow(_PHS_MPA, _ci5);
    a = _ai5;
    b = math.pow((100 / _TAmb_K), _bi5);
    c = math.pow(_PHS_MPA, _ci5);
    _rollingsum +=
        _ai6 * math.pow((100 / _TAmb_K), _bi6) * math.pow(_PHS_MPA, _ci6);
    a = _ai6;
    b = math.pow((100 / _TAmb_K), _bi6);
    c = math.pow(_PHS_MPA, _ci6);
    _rollingsum +=
        _ai7 * math.pow((100 / _TAmb_K), _bi7) * math.pow(_PHS_MPA, _ci7);
    a = _ai7;
    b = math.pow((100 / _TAmb_K), _bi7);
    c = math.pow(_PHS_MPA, _ci7);
    _rollingsum +=
        _ai8 * math.pow((100 / _TAmb_K), _bi8) * math.pow(_PHS_MPA, _ci8);
    a = _ai8;
    b = math.pow((100 / _TAmb_K), _bi8);
    c = math.pow(_PHS_MPA, _ci8);
    _rollingsum +=
        _ai9 * math.pow((100 / _TAmb_K), _bi9) * math.pow(_PHS_MPA, _ci9);
    a = _ai9;
    b = math.pow((100 / _TAmb_K), _bi9);
    c = math.pow(_PHS_MPA, _ci9);
    _ZHS = _rollingsum;

    _rollingsum = 1;
    _rollingsum +=
        _ai1 * math.pow((100 / _TAmb_K), _bi1) * math.pow(_PMS_MPA, _ci1);
    _rollingsum +=
        _ai2 * math.pow((100 / _TAmb_K), _bi2) * math.pow(_PMS_MPA, _ci2);
    _rollingsum +=
        _ai3 * math.pow((100 / _TAmb_K), _bi3) * math.pow(_PMS_MPA, _ci3);
    _rollingsum +=
        _ai4 * math.pow((100 / _TAmb_K), _bi4) * math.pow(_PMS_MPA, _ci4);
    _rollingsum +=
        _ai5 * math.pow((100 / _TAmb_K), _bi5) * math.pow(_PMS_MPA, _ci5);
    _rollingsum +=
        _ai6 * math.pow((100 / _TAmb_K), _bi6) * math.pow(_PMS_MPA, _ci6);
    _rollingsum +=
        _ai7 * math.pow((100 / _TAmb_K), _bi7) * math.pow(_PMS_MPA, _ci7);
    _rollingsum +=
        _ai8 * math.pow((100 / _TAmb_K), _bi8) * math.pow(_PMS_MPA, _ci8);
    _rollingsum +=
        _ai9 * math.pow((100 / _TAmb_K), _bi9) * math.pow(_PMS_MPA, _ci9);
    _ZMS = _rollingsum;

    _rollingsum = 1;
    _rollingsum +=
        _ai1 * math.pow((100 / _TAmb_K), _bi1) * math.pow(_PLS_MPA, _ci1);
    _rollingsum +=
        _ai2 * math.pow((100 / _TAmb_K), _bi2) * math.pow(_PLS_MPA, _ci2);
    _rollingsum +=
        _ai3 * math.pow((100 / _TAmb_K), _bi3) * math.pow(_PLS_MPA, _ci3);
    _rollingsum +=
        _ai4 * math.pow((100 / _TAmb_K), _bi4) * math.pow(_PLS_MPA, _ci4);
    _rollingsum +=
        _ai5 * math.pow((100 / _TAmb_K), _bi5) * math.pow(_PLS_MPA, _ci5);
    _rollingsum +=
        _ai6 * math.pow((100 / _TAmb_K), _bi6) * math.pow(_PLS_MPA, _ci6);
    _rollingsum +=
        _ai7 * math.pow((100 / _TAmb_K), _bi7) * math.pow(_PLS_MPA, _ci7);
    _rollingsum +=
        _ai8 * math.pow((100 / _TAmb_K), _bi8) * math.pow(_PLS_MPA, _ci8);
    _rollingsum +=
        _ai9 * math.pow((100 / _TAmb_K), _bi9) * math.pow(_PLS_MPA, _ci9);
    _ZLS = _rollingsum;
    _ZController.text = _ZLS.toStringAsFixed(4);

    _rollingsum = 1;
    _rollingsum +=
        _ai1 * math.pow((100 / _TAmb_K), _bi1) * math.pow(_PHE_MPA, _ci1);
    _rollingsum +=
        _ai2 * math.pow((100 / _TAmb_K), _bi2) * math.pow(_PHE_MPA, _ci2);
    _rollingsum +=
        _ai3 * math.pow((100 / _TAmb_K), _bi3) * math.pow(_PHE_MPA, _ci3);
    _rollingsum +=
        _ai4 * math.pow((100 / _TAmb_K), _bi4) * math.pow(_PHE_MPA, _ci4);
    _rollingsum +=
        _ai5 * math.pow((100 / _TAmb_K), _bi5) * math.pow(_PHE_MPA, _ci5);
    _rollingsum +=
        _ai6 * math.pow((100 / _TAmb_K), _bi6) * math.pow(_PHE_MPA, _ci6);
    _rollingsum +=
        _ai7 * math.pow((100 / _TAmb_K), _bi7) * math.pow(_PHE_MPA, _ci7);
    _rollingsum +=
        _ai8 * math.pow((100 / _TAmb_K), _bi8) * math.pow(_PHE_MPA, _ci8);
    _rollingsum +=
        _ai9 * math.pow((100 / _TAmb_K), _bi9) * math.pow(_PHE_MPA, _ci9);
    _ZHE = _rollingsum;

    _rollingsum = 1;
    _rollingsum +=
        _ai1 * math.pow((100 / _TAmb_K), _bi1) * math.pow(_PME_MPA, _ci1);
    _rollingsum +=
        _ai2 * math.pow((100 / _TAmb_K), _bi2) * math.pow(_PME_MPA, _ci2);
    _rollingsum +=
        _ai3 * math.pow((100 / _TAmb_K), _bi3) * math.pow(_PME_MPA, _ci3);
    _rollingsum +=
        _ai4 * math.pow((100 / _TAmb_K), _bi4) * math.pow(_PME_MPA, _ci4);
    _rollingsum +=
        _ai5 * math.pow((100 / _TAmb_K), _bi5) * math.pow(_PME_MPA, _ci5);
    _rollingsum +=
        _ai6 * math.pow((100 / _TAmb_K), _bi6) * math.pow(_PME_MPA, _ci6);
    _rollingsum +=
        _ai7 * math.pow((100 / _TAmb_K), _bi7) * math.pow(_PME_MPA, _ci7);
    _rollingsum +=
        _ai8 * math.pow((100 / _TAmb_K), _bi8) * math.pow(_PME_MPA, _ci8);
    _rollingsum +=
        _ai9 * math.pow((100 / _TAmb_K), _bi9) * math.pow(_PME_MPA, _ci9);
    _ZME = _rollingsum;

    _rollingsum = 1;
    _rollingsum +=
        _ai1 * math.pow((100 / _TAmb_K), _bi1) * math.pow(_PLE_MPA, _ci1);
    _rollingsum +=
        _ai2 * math.pow((100 / _TAmb_K), _bi2) * math.pow(_PLE_MPA, _ci2);
    _rollingsum +=
        _ai3 * math.pow((100 / _TAmb_K), _bi3) * math.pow(_PLE_MPA, _ci3);
    _rollingsum +=
        _ai4 * math.pow((100 / _TAmb_K), _bi4) * math.pow(_PLE_MPA, _ci4);
    _rollingsum +=
        _ai5 * math.pow((100 / _TAmb_K), _bi5) * math.pow(_PLE_MPA, _ci5);
    _rollingsum +=
        _ai6 * math.pow((100 / _TAmb_K), _bi6) * math.pow(_PLE_MPA, _ci6);
    _rollingsum +=
        _ai7 * math.pow((100 / _TAmb_K), _bi7) * math.pow(_PLE_MPA, _ci7);
    _rollingsum +=
        _ai8 * math.pow((100 / _TAmb_K), _bi8) * math.pow(_PLE_MPA, _ci8);
    _rollingsum +=
        _ai9 * math.pow((100 / _TAmb_K), _bi9) * math.pow(_PLE_MPA, _ci9);
    _ZLE = _rollingsum;

    a = ((_PHE_MPA * _Liters_CF * _molar_mass) /
        (_ZHE * _TAmb_K * _gas_constant));
    b = ((_PHS_MPA * _Liters_CF * _molar_mass) /
        (_ZHS * _TAmb_K * _gas_constant));
    c = (a - b);

    a = ((_PLS_MPA * _Liters_CF * _molar_mass) /
        (_ZLS * _TAmb_K * _gas_constant));

    _KGH = ((_PHE_MPA * _Liters_CF * _molar_mass) /
            (_ZHE * _TAmb_K * _gas_constant)) -
        ((_PHS_MPA * _Liters_CF * _molar_mass) /
            (_ZHS * _TAmb_K * _gas_constant));
    _KGM = ((_PME_MPA * _Liters_CF * _molar_mass) /
            (_ZME * _TAmb_K * _gas_constant)) -
        ((_PMS_MPA * _Liters_CF * _molar_mass) /
            (_ZMS * _TAmb_K * _gas_constant));
    _KGL = ((_PLE_MPA * _Liters_CF * _molar_mass) /
            (_ZLE * _TAmb_K * _gas_constant)) -
        ((_PLS_MPA * _Liters_CF * _molar_mass) /
            (_ZLS * _TAmb_K * _gas_constant));

    _DensityKG_CFController.text = a.toStringAsFixed(4); // per CF

    _KGTotal = (_KGH * _VH_CF) +
        (_KGM * _VM_CF) +
        (_KGL * _VL_CF); //This is total KG pumped

    _flowrate = _KGTotal * (3600 / _timercounter); //This the rate in KG/Min
    _strflow = _KGTotal.toStringAsFixed(2);
    _strflowrate = _flowrate.toStringAsFixed(2);
  }

//End _MyHomePageState class
}

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({this.decimalRange})
      : assert(decimalRange == null || decimalRange > 0);

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;

    if (decimalRange != null) {
      String value = newValue.text;

      if (value.contains(".") &&
          value.substring(value.indexOf(".") + 1).length > decimalRange) {
        truncated = oldValue.text;
        newSelection = oldValue.selection;
      } else if (value == ".") {
        truncated = "0.";

        newSelection = newValue.selection.copyWith(
          baseOffset: math.min(truncated.length, truncated.length + 1),
          extentOffset: math.min(truncated.length, truncated.length + 1),
        );
      }

      return TextEditingValue(
        text: truncated,
        selection: newSelection,
        composing: TextRange.empty,
      );
    }
    return newValue;
  }
}
