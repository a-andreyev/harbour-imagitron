#include "imagitronobject.h"

ImagitronObject::ImagitronObject(int index, const QString &url, const QString &previewUrl, const QString &title, QObject *parent) :
    QObject(parent)
{
    setTitle(title);
    setIndex(index);
    _remoteUrl = url;
    _remotePreviewUrl = previewUrl;
    setMimeType("image/jpeg");
    connect(this,SIGNAL(updateUrlsToCached()),this,SLOT(downloadFiles()));
    // emit updateUrlsToCached();
}

QString ImagitronObject::title() const
{
    return _title;
}

QUrl ImagitronObject::url() const
{
    return _url;
}

QString ImagitronObject::mimeType() const
{
    return _mimeType;
}

QUrl ImagitronObject::previewUrl() const
{
    if (!_previewUrl.isEmpty()) {
        return _previewUrl;
    }
    else {
        if (_url.isValid()) {
            return _url;
        }
    }
    return QUrl();
}

int ImagitronObject::index() const
{
    return _index;
}

void ImagitronObject::setTitle(QString title)
{
    if (_title == title)
        return;

    _title = title;
    emit titleChanged(title);
}

void ImagitronObject::setUrl(QUrl url)
{
    if (_url == url)
        return;
    _url = url;
    emit urlChanged(_url);
}

void ImagitronObject::setPreviewUrl(QUrl url)
{
    if (_previewUrl == url)
        return;
    _previewUrl = url;
    emit previewUrlChanged(_previewUrl);
}

void ImagitronObject::setMimeType(QString mimeType)
{
    if (_mimeType == mimeType)
        return;
    _mimeType = mimeType;
    emit mimeTypeChanged(_mimeType);
}

void ImagitronObject::onObjectCached(QString fileName, bool isPreview)
{
    QString path = QString("file://")+fileName;
    if (isPreview) {
        setPreviewUrl(path);
    }
    else {
        setUrl(path);
    }
}

void ImagitronObject::downloadFiles()
{
    connect(&_fd,SIGNAL(saveFileSucceeded(QString,bool)),this,SLOT(onObjectCached(QString,bool)));
    connect(&_pfd,SIGNAL(saveFileSucceeded(QString,bool)),this,SLOT(onObjectCached(QString,bool)));
    _fd.saveFile(_remoteUrl,_title,false);
    _pfd.saveFile(_remotePreviewUrl,_title,true);

}

void ImagitronObject::setIndex(int index)
{
    if (_index == index)
        return;

    _index = index;
    emit indexChanged(index);
}
