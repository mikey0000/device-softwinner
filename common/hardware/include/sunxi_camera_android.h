// Copyright (c) 2016 Kamil Trzciński <ayufan@ayufan.eu>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// This file adds a missing camera values required by Allwinner HW camera module
// Original MR: https://github.com/ayufan-pine64/system-core/pull/2

#ifndef __CAMERA_ANDROID_H__
#define __CAMERA_ANDROID_H__

/** msgType in notifyCallback and dataCallback functions */
enum {
    CAMERA_MSG_CONTINUOUSSNAP = 0x1000,    //notifyCallback for continuous snap
    CAMERA_MSG_SNAP = 0x2000,              //notifyCallback of setting camera idle  for single snap
    CAMERA_MSG_SNAP_THUMB = 0x4000,        //notifyCallback of saving thumb for single snap
    CAMERA_MSG_SNAP_FD= 0x8000,            //notifyCallback of requesting fd for single and continuoussnap
};

/** msgType in Smart mode notifyCallback */
enum {
    CAMERA_SMART_MSG_STATUS = 0xF001,          // notifyCallback
};

/** result in smart detection */
enum {
    SMART_STATUS_UNKNOWN          = 0x00,
    SMART_STATUS_ERROR            = 0x01,
    SMART_STATUS_ROTATION_0       = 0x10,
    SMART_STATUS_ROTATION_90      = 0x20,
    SMART_STATUS_ROTATION_180     = 0x40,
    SMART_STATUS_ROTATION_270     = 0x80,
};

/** cmdType in sendCommand functions */
enum {
    /**
    * Start the smart detection.
    */
    CAMERA_CMD_START_SMART_DETECTION = 100,

    /**
    * Stop the smart detection.
    */
    CAMERA_CMD_STOP_SMART_DETECTION = 200,

    CAMERA_CMD_SET_SCREEN_ID = 0xFF000000,
    CAMERA_CMD_SET_CEDARX_RECORDER = 0xFF000001
};


/**
 * The metadata of the face detection result.
 */
typedef struct camera_face_smile_status {
    /**
     * The number of detected faces in the frame.
     */
    int32_t number_of_smiles;
    /**
     * An array of the detected smiles. The length is number_of_smiles.
     */
    int32_t *smiles;
} camera_face_smile_status_t;


/**
 * The metadata of the face detection result.
 */
typedef struct camera_face_blink_status {
    /**
     * The number of detected faces in the frame.
     */
    int32_t number_of_blinks;
    /**
     * An array of the detected blinks. The length is number_of_blinks.
     */
    int32_t *blinks;
} camera_face_blink_status_t;

#endif // __CAMERA_ANDROID_H__
