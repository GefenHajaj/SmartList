import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class InfoPage extends StatefulWidget {
  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  Widget _getBody() {
    return SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30.0, 40.0, 30.0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.rtl,
              children: <Widget>[
                Text(
                  'מי אנחנו?',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: Colors.black54,
                    letterSpacing: 2.0,
                  ),
                ),
                SizedBox(height: 10.0),
                Text(
                  'אנחנו Super List, האפליקציה שנועדה לעזור לכם בכל סוג של קניות!\nבין אם זה קניות לבית, לטיול עם חברים או למשרד - צרו רשימה חדשה, שתפו עם חברים ותתחילו לעשות סדר בקניות שלכם!',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    letterSpacing: 2.0,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                SizedBox(height: 40.0),
                Text(
                  'אז... איך זה עובד?',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: Colors.black54,
                    letterSpacing: 2.0,
                  ),
                ),
                SizedBox(height: 10.0),
                Text(
                  'לאחר שיצרתם רשימה, בדף הבית תוכלו לשתף את הרשימה עם חברים ומשפחה על ידי לחיצה על אייקון השיתוף. כך תוכלו לנהל ביחד את הרשימה שלכם, להוסיף לה מוצרים ולסמן את מה שקניתם!\n\nלחצו לחיצה קצרה על מוצר כדי לסמן אותו כנקנה, ולחיצה ארוכה כדי לערוך אותו. בהגדרות הרשימה תוכלו לראות את פרטי הרשימה והמשתתפים בה.\n\nתהנו!',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    letterSpacing: 2.0,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                SizedBox(height: 40.0),
                Text(
                  'יזם הרעיון',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: Colors.grey,
                    letterSpacing: 2.0,
                  ),
                ),
                SizedBox(height: 10.0),
                Text(
                  'יניר ברט',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    letterSpacing: 2.0,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                SizedBox(height: 10.0),
                Row(
                  children: [
                    Wrap(
                      children: <Widget>[
                        Icon(
                          Icons.email,
                          color: Colors.black,
                        ),
                        SizedBox(width: 10.0),
                        Text(
                          'smartlistapp2020@gmail.com',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18.0,
                            letterSpacing: 1.0,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 40.0),
                Text(
                  'אחראי טכנולוגי ומפתח האפליקציה',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: Colors.grey,
                    letterSpacing: 2.0,
                  ),
                ),
                SizedBox(height: 10.0),
                Text(
                  'גפן חגאגי',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    letterSpacing: 2.0,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                SizedBox(height: 10.0),
                Row(
                  children: [
                    Wrap(
                      children: <Widget>[
                        Icon(
                          Icons.email,
                          color: Colors.black,
                        ),
                        SizedBox(width: 10.0),
                        Text(
                          'gefenhajaj@gmail.com',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18.0,
                            letterSpacing: 1.0,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 100.0),
                Center(
                  child: Text(
                    "כל הזכויות שמורות ליניר ברט ©\n2020",
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 60.0),
              ],
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        iconTheme: IconThemeData(
          color: Colors.black54, //change your color here
        ),
        title: Text(
          "אודות",
          textDirection: TextDirection.rtl,
          style: TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _getBody(),
    );
  }
}
