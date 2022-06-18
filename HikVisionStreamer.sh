cacheVideo="~/secureCam.mp4"
echo "Input your camera's ip:port:"
read networkLocation
echo "Input your username:"
read username
echo "Enter your password:"
read password
hwaccelAPI=vaapi
echo "Input where you'd like to store your video:"
read filePath
length="12:00:00"
size="1280x720"

function checkLast(){
    if [ -f ${cacheVideo} ]; then
        mv ${cacheVideo} ${filePath}/Recovered_Video_at_`date "+%Y-%m-%d_%H-%M-%S"`.mp4
        echo "Warning! Detected a non-complete video!"
    fi
}

function cacheVideo(){
    startTime=`date "+%Y-%m-%d_%H-%M-%S"`
    if [[ $@ =~ "vaapi" ]]; then
        ffmpeg -rtsp_transport tcp -init_hw_device vaapi=foo:/dev/dri/renderD128 -hwaccel vaapi -hwaccel_output_format vaapi -hwaccel_device foo -i rtsp://${username}:${password}@${networkLocation}/h264/ch1/main/av_stream -t ${length}  -filter_hw_device foo -vf 'format=nv12|vaapi,hwupload' -c:v hevc_vaapi ${cacheVideo}
    else
         ffmpeg -rtsp_transport tcp -i rtsp://${username}:${password}@${networkLocation}/h264/ch1/main/av_stream -t ${length} ${cacheVideo}
    fi
    endTime=`date "+%Y-%m-%d_%H-%M-%S"`
}

function saveVideo(){
    saveFile="${filePath}/${startTime}-${endTime}.mp4"
    mv ${cacheVideo} "${filePath}/${startTime}-${endTime}.mp4"
}

function stream(){
    while [ True ]; do
        checkLast
        cacheVideo
        saveVideo
        echo "New video saved to ${filePath}/Saved_${startTime}-${endTime}.mp4 at `date`."
        unset endTime
        unset startTime
    done
}

stream

