#include "filedownloader.h"

#include <QtCore/QUrl>
#include <QtGui/QClipboard>
#include <QNetworkRequest>
#include <QStandardPaths>
#include <QDir>

FileDownloader::FileDownloader(QObject *parent) :
 QObject(parent)
{

}

void FileDownloader::saveFile(const QString &url, const QString &title, bool isPreview)
{
    _url = QUrl(url);
    _isPreview = isPreview;
    QString picturesLocation = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
    // TODO: define names
    if (isPreview) {
        picturesLocation+="/small/";
    }
    else {
        picturesLocation+="/large/";
    }
    QDir dir(picturesLocation);
    if (!dir.exists()) {
        dir.mkpath(".");
    }
    QString targetFileName = picturesLocation + title;

    _imageFile.setFileName(targetFileName);

    connect(this,SIGNAL(imageChecked(bool)),this,SLOT(onImageChecked(bool)));
    _checkFile();
}

void FileDownloader::onReadyRead()
{
    if (!_reply->error()) {
        if (_imageFile.open(QIODevice::WriteOnly)) {
            _imageFile.write(_reply->readAll());
            _imageFile.close();
            _checkFile();
        }
    }
    _reply->deleteLater();
    _reply = 0;
}

void FileDownloader::onImageChecked(bool isCorrupted)
{
    if (isCorrupted) {
        _getImage();
        return;
    }
    emit saveFileSucceeded(_imageFile.fileName(),_isPreview);
}

void FileDownloader::_checkFile()
{
    int eofmarksz = 2;
    char eofmark[eofmarksz];
    eofmark[0]=0xFF;
    eofmark[1]=0xD9;
    // TODO: fix QImageReaderBug
    if (_imageFile.open(QIODevice::ReadOnly)) {
        if (_imageFile.readAll().right(eofmarksz)==
                QByteArray::fromRawData(eofmark,eofmarksz)) {
            emit imageChecked(false); // no errors
            return;
        };
    }
    emit imageChecked(true); // errors
}

void FileDownloader::_getImage()
{
    _reply = _manager.get(QNetworkRequest(_url));
    connect(_reply, SIGNAL(finished()), this, SLOT(onReadyRead()));
}
