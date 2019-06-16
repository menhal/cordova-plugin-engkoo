package com.edufe.engkoo;

import android.media.MediaPlayer;
import android.media.MediaRecorder;
import android.os.Environment;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.LOG;

import java.io.File;
import java.io.IOException;
import java.util.LinkedList;


public class AudioRecoder  {

    public enum MODE { NONE, PLAY, RECORD };

    public enum STATE { MEDIA_NONE,
        MEDIA_STARTING,
        MEDIA_RUNNING,
        MEDIA_PAUSED,
        MEDIA_STOPPED,
        MEDIA_LOADING
    };

    private static final String LOG_TAG = "AudioPlayer";

    private CordovaPlugin handler;           
    private STATE state = STATE.MEDIA_NONE; 

    private String audioFile = null;  

    private MediaRecorder recorder = null; 
    private LinkedList<String> tempFiles = null; 
    private String tempFile = null;


    public AudioRecoder(CordovaPlugin handler, String id, String file) {
        this.handler = handler;
        this.audioFile = file;
        this.tempFiles = new LinkedList<String>();
    }

    private String generateTempFile() {
        String tempFileName = null;
        if (Environment.getExternalStorageState().equals(Environment.MEDIA_MOUNTED)) {
            tempFileName = Environment.getExternalStorageDirectory().getAbsolutePath() + "/tmprecording-" + System.currentTimeMillis() + ".3gp";
        } else {
            tempFileName = "/data/data/" + handler.cordova.getActivity().getPackageName() + "/cache/tmprecording-" + System.currentTimeMillis() + ".3gp";
        }
        return tempFileName;
    }

    public void destroy() {
        if (this.recorder != null) {
            this.stopRecording();
            this.recorder.release();
            this.recorder = null;
        }
    }

    public void startRecording(String file) {
        this.audioFile = file;
        this.recorder = new MediaRecorder();
        this.recorder.setAudioSource(MediaRecorder.AudioSource.MIC);
        this.recorder.setOutputFormat(MediaRecorder.OutputFormat.RAW_AMR); // RAW_AMR);
        this.recorder.setAudioEncoder(MediaRecorder.AudioEncoder.AMR_NB); //AMR_NB);
        this.tempFile = generateTempFile();
        this.recorder.setOutputFile(this.tempFile);
        try {
            this.recorder.prepare();
            this.recorder.start();
            return;
        } catch (IllegalStateException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public String moveFile(String file) {

        if (!file.startsWith("/")) {
            if (Environment.getExternalStorageState().equals(Environment.MEDIA_MOUNTED)) {
                file = Environment.getExternalStorageDirectory().getAbsolutePath() + File.separator + file;
            } else {
                file = "/data/data/" + handler.cordova.getActivity().getPackageName() + "/cache/" + file;
            }
        }

        String logMsg = "renaming " + this.tempFile + " to " + file;
        File f = new File(this.tempFile);
        if (!f.renameTo(new File(file))) LOG.e(LOG_TAG, "FAILED " + logMsg);

        return file;
    }

    public String stopRecording() {
        if (this.recorder != null) {
            try{
                if (this.state == STATE.MEDIA_RUNNING) {
                    this.recorder.stop();
                }
                this.recorder.reset();
                if (!this.tempFiles.contains(this.tempFile)) {
                    this.tempFiles.add(this.tempFile);
                }
                return this.moveFile(this.audioFile);
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }

        return "";
    }

}
