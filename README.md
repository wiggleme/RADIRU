# らじる☆らじるを再生・録音します。

## 実行環境
　Linux、macOS  
　再生：mplayer  
　録音：ffmpeg  
## 動作確認環境
　Raspberry Pi 3 model A、Raspbian Stretch  
　ChromeBook Acer CB3-111、Gallium OS  
　MacBook 2016、Mojave  
## インストール
　*.shをパスの通ったディレクトリに置いてください。  
## 使用方法
　$ nhk_radio.sh  [options]  duration(sec/min)  
　-a artist: set artist name (rec)  
　-b buffer: set buffer size [10sec] (play, 1=10sec..20=200sec)  
　-c channel: r1, r2, or fm  
　-d device: playback device name (play, linux)  
　-f file: set file name (rec)  
　-m: set duration as minutes (default seconds)  
　-p: play radio (default)  
　-r: record radio  
　-s station: select station, sapporo, sendai, tokyo(default),nagoya, osaka, hiroshima, matsuyama, or fukuoka  
　再生・録音の中断は“stop_radio.sh”を実行してください。  
　録音したファイルは“~/radio”に作成されます。フォーマットはm4aです。  
