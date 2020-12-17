package com.dartbase.blackbox;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.Context;
import android.os.Build;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.core.app.NotificationCompat;
import androidx.work.Data;
import androidx.work.Worker;
import androidx.work.WorkerParameters;

import java.util.concurrent.TimeUnit;

import static com.dartbase.blackbox.MainActivity._period;
import static com.dartbase.blackbox.MainActivity.fileName;

public class BackgroundWorker extends Worker {


    private static final String WORK_RESULT = "work_result";
    public BackgroundWorker(@NonNull Context context, @NonNull WorkerParameters workerParams) {
        super(context, workerParams);
    }
    @NonNull
    @Override
    public Result doWork() {
        Data taskData = getInputData();
        String taskDataString = taskData.getString(MainActivity.MESSAGE_STATUS);
        showNotification("Black Box", taskDataString != null ? taskDataString : "Will work in the period " + String.valueOf(_period) + " Minutes");
        Data outputData = new Data.Builder().putString(WORK_RESULT, "Jobs Finished").build();

        RecoderManager recoderManager = new RecoderManager();
        recoderManager.recordStart(fileName);

        try {

            Thread.sleep(_period * 60000); ////////////// 60000 for minutes /// 1000 for seconds
            recoderManager.recordStop();

        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        return Result.success(outputData);
    }
    private void showNotification(String task, String desc) {
        NotificationManager manager = (NotificationManager) getApplicationContext().getSystemService(Context.NOTIFICATION_SERVICE);
        String channelId = "task_channel";
        String channelName = "task_name";
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new
                    NotificationChannel(channelId, channelName, NotificationManager.IMPORTANCE_DEFAULT);
            manager.createNotificationChannel(channel);
        }
        NotificationCompat.Builder builder = new NotificationCompat.Builder(getApplicationContext(), channelId)
                .setContentTitle(task)
                .setContentText(desc)
                .setSmallIcon(R.mipmap.ic_launcher);
        manager.notify(1, builder.build());
    }
}
