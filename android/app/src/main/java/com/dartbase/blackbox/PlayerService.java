package com.dartbase.blackbox;

import android.app.Service;
import android.content.Intent;
import android.media.MediaRecorder;
import android.os.Environment;
import android.os.IBinder;
import android.support.v4.media.session.MediaSessionCompat;
import android.support.v4.media.session.PlaybackStateCompat;
import android.widget.Toast;

import androidx.media.VolumeProviderCompat;

import java.sql.Time;
import java.text.SimpleDateFormat;
import java.util.Date;

import static com.dartbase.blackbox.MainActivity._timeStart;
import static com.dartbase.blackbox.MainActivity.currentUser;

public class PlayerService extends Service {
    private MediaSessionCompat mediaSession;
    VolumeProviderCompat myVolumeProvider;

    RecoderManager recoderManager;

    boolean recoderManagerWork = false;

    private String fileName;

    int curValue = 50;

    @Override
    public void onCreate() {
        super.onCreate();

        Date dateNow = new Date();
        SimpleDateFormat formatForDateNow = new SimpleDateFormat("yyyy_MM_dd-hh_mm_ss");

        recoderManager = new RecoderManager();

        recoderManager = new RecoderManager();
        fileName = "/storage/emulated/0/Android/data/com.dartbase.blackbox/files/"
                + currentUser
                + "-Black Box-KEY"
                + formatForDateNow.format(dateNow).toString() + ".m4a";

        mediaSession = new MediaSessionCompat(this, "PlayerService");
        mediaSession.setFlags(MediaSessionCompat.FLAG_HANDLES_MEDIA_BUTTONS |
                MediaSessionCompat.FLAG_HANDLES_TRANSPORT_CONTROLS);
        mediaSession.setPlaybackState(new PlaybackStateCompat.Builder()
                .setState(PlaybackStateCompat.STATE_PLAYING, 0, 0) //you simulate a player which plays something.
                .build());

        myVolumeProvider =
                new VolumeProviderCompat(VolumeProviderCompat.VOLUME_CONTROL_RELATIVE, /*max volume*/100, /*initial volume level*/50) {
                    @Override
                    public void onAdjustVolume(int direction) {
                        if (direction > 0) {
                            curValue += 1;

                            if (curValue >= 100) {
                                curValue = 100;
                                Toast.makeText(getApplicationContext(), "UP", Toast.LENGTH_SHORT).show();

                                if (recoderManagerWork) {
                                    Toast.makeText(getApplicationContext(), "The recording is already working", Toast.LENGTH_SHORT).show();
                                } else {
                                    recoderManagerWork = true;
                                    recoderManager.recordStart(fileName);
                                }
                            }
                        }
                        else if (direction == 0){
                            curValue = 50;
                        }
                        else if (direction < 0) {
                            curValue -= 1;

                            if (curValue <= 0) {
                                curValue = 0;
                                Toast.makeText(getApplicationContext(), "DOWN", Toast.LENGTH_SHORT).show();

                                if (recoderManagerWork) {
                                    recoderManager.recordStop();
                                    recoderManagerWork = false;
                                } else {
                                    Toast.makeText(getApplicationContext(), "Press the sound up button (MAX) to start", Toast.LENGTH_SHORT).show();
                                }
                            }
                        }
                    }
                };

        mediaSession.setPlaybackToRemote(myVolumeProvider);
        mediaSession.setActive(true);
    }


    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        mediaSession.release();
    }
}
