package com.edufe.engkoo;

import android.media.MediaPlayer;
import android.media.MediaRecorder;
import android.os.Environment;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.LOG;

import java.io.File;
import java.io.IOException;
import java.util.LinkedList;

/**
 * This class implements the audio playback and recording capabilities used by Cordova.
 * It is called by the AudioHandler Cordova class.
 * Only one file can be played or recorded per class instance.
 *
 * Local audio files must reside in one of two places:
 *      android_asset:      file name must start with /android_asset/sound.mp3
 *      sdcard:             file name is just sound.mp3
 */
public class AudioRecoder  {

    // AudioPlayer modes
    public enum MODE { NONE, PLAY, RECORD };

    // AudioPlayer states
    public enum STATE { MEDIA_NONE,
        MEDIA_STARTING,
        MEDIA_RUNNING,
        MEDIA_PAUSED,
        MEDIA_STOPPED,
        MEDIA_LOADING
    };

    private static final String LOG_TAG = "AudioPlayer";

    private CordovaPlugin handler;           // The AudioHandler object
    private STATE state = STATE.MEDIA_NONE; // State of recording or playback

    private String audioFile = null;        // File name to play or record to

    private MediaRecorder recorder = null;  // Audio recording object
    private LinkedList<String> tempFiles = null; // Temporary recording file name
    private String tempFile = null;

    /**
     * Constructor.
     *
     * @param handler           The audio handler object
     * @param id                The id of this audio player
     */
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

    /**
     * Destroy player and stop audio playing or recording.
     */
    public void destroy() {
        if (this.recorder != null) {
            this.stopRecording();
            this.recorder.release();
            this.recorder = null;
        }
    }

    /**
     * Start recording the specified file.
     *
     * @param file              The name of the file
     */
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

    /**
     * Save temporary recorded file to specified name
     *
     * @param file
     */
    public void moveFile(String file) {
        /* this is a hack to save the file as the specified name */

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
    }

    /**
     * Stop/Pause recording and save to the file specified when recording started.
     */
    public void stopRecording() {
        if (this.recorder != null) {
            try{
                if (this.state == STATE.MEDIA_RUNNING) {
                    this.recorder.stop();
                }
                this.recorder.reset();
                if (!this.tempFiles.contains(this.tempFile)) {
                    this.tempFiles.add(this.tempFile);
                }
                this.moveFile(this.audioFile);
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

}
