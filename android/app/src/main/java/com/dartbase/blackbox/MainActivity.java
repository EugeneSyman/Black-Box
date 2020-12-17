package com.dartbase.blackbox;

import android.accounts.Account;
import android.content.Context;
import android.content.Intent;
import android.database.ContentObserver;
import android.media.AudioManager;
import android.media.VolumeProvider;
import android.os.Bundle;
import android.os.Handler;
import android.provider.ContactsContract;
import android.view.KeyEvent;
import android.view.WindowManager;
import android.widget.Toast;

import io.flutter.Log;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.embedding.android.FlutterActivity;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.Observer;
import androidx.media.VolumeProviderCompat;
import androidx.work.OneTimeWorkRequest;
import androidx.work.WorkInfo;
import androidx.work.WorkManager;
import androidx.work.Worker;

import net.sqlcipher.database.SQLiteDatabase;

import java.sql.Struct;
import java.util.ArrayList;
import java.util.concurrent.TimeUnit;

public class MainActivity extends FlutterActivity {

    public static final String MESSAGE_STATUS = "message_status";

    public static String currentUser = "Emergency call";

    public static String fileName;
    public static long _timeStart = 0;
    public static long _period = 0;

    public static String _nikeName;
    public static String _password;

    public static boolean workService = false;
    public Intent Service;

    DBHelper dbHelper;

    int answer = 0;
    String answerSTR;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // TODO: BLOCK SCREENSHOT //////////////////////////////////////////////////////
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_SECURE,WindowManager.LayoutParams.FLAG_SECURE);
        //
        // TODO: DATA BASE (256-bit AES) //////////////////////////////////////////////
        SQLiteDatabase.loadLibs(this);
        dbHelper.initialization(this);
        //
        // TODO: MethodChannel ////////////////////////////////////////////////////////
        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), "com.dartbase.blackbox")
                .setMethodCallHandler(new MethodChannel.MethodCallHandler() {
                    @Override
                    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {

                        if (call.method.equals("createBackgroundWorker")) {
                            _timeStart = Long.parseLong(call.argument("TimeStart").toString());
                            _period = Long.parseLong(call.argument("Period").toString());
                            fileName = call.argument("Path").toString();

                            startBackgroundWorker(_timeStart);
                        }
                        if (call.method.equals("startBackgroundLogin")) {
                            _nikeName = call.argument("NikeName").toString();
                            _password = call.argument("Password").toString();

                            answer = startBackgroundLogin(_nikeName, _password);
                        }
                        if (call.method.equals("getCurrentUser")) {
                            answerSTR = getCurrentUser();
                        }
                        if (call.method.equals("setListeningService")) {
                            answerSTR = setListeningService();
                        }

                        result.success(answerSTR + "|" + String.valueOf(answer) + "|" + _timeStart + "   " + _period + " " + _nikeName + " " + _password);
                    }
                });

        // TODO: External trigger ////////////////////////////////////////////////////
        Service = new Intent(this, PlayerService.class);
    }


    private String getCurrentUser() {
        return currentUser;
    }

    private String setListeningService() {
        String answer;
        if (workService){
            stopService(Service);
            workService = false;
            answer = "false";
        }
        else {
            startService(Service);
            workService = true;
            answer = "true";
        }
        return answer;
    }


    private int startBackgroundLogin(String nikeName, String password) {

        DBHelper.Account account = new DBHelper.Account(nikeName, password);

        ArrayList<DBHelper.Account> accounts = DBHelper.selectAccounts();

        for (int i = 0; i < accounts.size(); i++) {
            if (accounts.get(i).getNickname().equals(nikeName) && accounts.get(i).getPassword().equals(password)) {
                currentUser = nikeName;
                return 1;
            }
        }

        for (int i = 0; i < accounts.size(); i++) {
            if (accounts.get(i).getNickname().equals(nikeName)) {
                return 2;
            }
        }

        if (dbHelper.InsertAccount(account)) {
            return 3;
        }

        return 4;
    }


    public void startBackgroundWorker(long _timeStart) {
        final WorkManager mWorkManager = WorkManager.getInstance();
        final OneTimeWorkRequest mRequest = new OneTimeWorkRequest.
                Builder(BackgroundWorker.class)
                .setInitialDelay(_timeStart, TimeUnit.MINUTES)
                .build();

        mWorkManager.enqueue(mRequest);

        mWorkManager.getWorkInfoByIdLiveData(mRequest.getId()).observe(this, new Observer<WorkInfo>() {
            @Override
            public void onChanged(@Nullable WorkInfo workInfo) {
                if (workInfo != null) {
                    WorkInfo.State state = workInfo.getState();
                }
            }
        });
    }
}



