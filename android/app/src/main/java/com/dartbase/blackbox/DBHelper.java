package com.dartbase.blackbox;

import android.accounts.Account;
import android.content.ContentValues;
import android.content.Context;
import android.database.sqlite.SQLiteConstraintException;
import android.util.Log;

import net.sqlcipher.Cursor;
import net.sqlcipher.database.SQLiteDatabase;
import net.sqlcipher.database.SQLiteOpenHelper;

import java.util.ArrayList;
import java.util.List;

public class DBHelper extends SQLiteOpenHelper {

    public static class Account {

        private String nickname;
        private String password;

        public Account(String _nickname, String _password) {
            this.nickname = _nickname;
            this.password = _password;
        }

        public String getNickname() {
            return nickname;
        }

        public String getPassword() {
            return password;
        }

    }

    public static final ArrayList<Account> accounts = new ArrayList<>();

    private static final String TAG = "DBHelper";
    private static final String Password = "nXn-nwc-yuc-sg4";

    private static final int SCHEMA = 1;
    private static final String DATABASE_NAME = "NEXUS";

    private static Cursor cursor;
    public static SQLiteDatabase db;
    private static ContentValues contentValues;


    // TODO: ///////// STRUCTURE TABLE
    public static final String TABLE_ACCOUNTS = "Accounts";
    public static final String COLUMN_ID = "_id";
    public static final String COLUMN_PASSWORD = "Password";
    public static final String COLUMN_NICKNAME = "Nickname";

    public DBHelper(Context context) {
        super(context, DATABASE_NAME, null, SCHEMA);
        SQLiteDatabase.loadLibs(context);
    }

    public static DBHelper sqlHelper;

    public static void initialization(Context context) {
        sqlHelper = new DBHelper(context);
        db = sqlHelper.getWritableDatabase();
    }

    public SQLiteDatabase getReadableDatabase() {
        return (super.getReadableDatabase(Password));
    }

    public SQLiteDatabase getWritableDatabase() {
        return (super.getWritableDatabase(Password));
    }


    @Override
    public void onCreate(SQLiteDatabase db) {

        try {
            // TODO: PRAGMA
            db.execSQL("PRAGMA foreign_keys=on");

            // TODO: ///////// TABLES
            db.execSQL("CREATE TABLE  Accounts  (" +
                    " _id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE," +
                    " Nickname  TEXT NOT NULL UNIQUE," +
                    " Password TEXT NOT NULL" +
                    ")");
        } catch (SQLiteConstraintException e) {
            Log.e(TAG, e.toString());
        }
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        db.execSQL("DROP TABLE IF EXISTS " + TABLE_ACCOUNTS);

        onCreate(db);
    }

    // TODO:///////////  CRUD
    public static ArrayList<Account> selectAccounts() {

        cursor = db.rawQuery("SELECT * FROM Accounts", null);
        while (cursor.moveToNext()) {
            accounts.add(new Account(
                    cursor.getString(cursor.getColumnIndex(DBHelper.COLUMN_NICKNAME)),
                    cursor.getString(cursor.getColumnIndex(DBHelper.COLUMN_PASSWORD))
            ));
        }
        cursor.close();
        return accounts;
    }


    public static boolean InsertAccount(Account _account) {
        contentValues = new ContentValues();

        contentValues.put(DBHelper.COLUMN_NICKNAME, _account.getNickname());
        contentValues.put(DBHelper.COLUMN_PASSWORD, _account.getPassword());

        db.insert(DBHelper.TABLE_ACCOUNTS, null, contentValues);

        cursor = db.rawQuery("SELECT * FROM Accounts ORDER BY _id DESC LIMIT 1", null);

        cursor.moveToFirst();

        return true;
    }
}
