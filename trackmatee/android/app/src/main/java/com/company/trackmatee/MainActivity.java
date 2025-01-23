package com.company.trackmatee;

import android.os.Bundle;
import android.database.sqlite.SQLiteDatabase;
import android.content.ContentValues;
import android.database.Cursor;
import android.util.Log;
import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {
    private static final String TAG = "MainActivity";
    private DatabaseHelper dbHelper;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        dbHelper = new DatabaseHelper(this);

        // Insert data
        insertData("exampleName", "exampleValue");

        // Retrieve data
        retrieveData();
    }

    private void insertData(String name, String value) {
        SQLiteDatabase db = dbHelper.getWritableDatabase();
        ContentValues values = new ContentValues();
        values.put("name", name);
        values.put("value", value);
        long newRowId = db.insert("your_table", null, values);
        Log.d(TAG, "New row ID: " + newRowId);
    }

    private void retrieveData() {
        SQLiteDatabase db = dbHelper.getReadableDatabase();
        String[] projection = {
                "id",
                "name",
                "value"
        };

        Cursor cursor = db.query(
                "your_table",
                projection,
                null,
                null,
                null,
                null,
                null
        );

        while (cursor.moveToNext()) {
            long itemId = cursor.getLong(cursor.getColumnIndexOrThrow("id"));
            String itemName = cursor.getString(cursor.getColumnIndexOrThrow("name"));
            String itemValue = cursor.getString(cursor.getColumnIndexOrThrow("value"));
            Log.d(TAG, "ID: " + itemId + ", Name: " + itemName + ", Value: " + itemValue);
        }
        cursor.close();
    }
}