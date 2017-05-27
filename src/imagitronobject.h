#ifndef IMAGITRONOBJECT_H
#define IMAGITRONOBJECT_H

#include <QObject>
#include <QUrl>
#include "filedownloader.h"

class ImagitronObject : public QObject
{
    Q_OBJECT
    // TODO: progress
    Q_PROPERTY(QString title READ title NOTIFY titleChanged)
    Q_PROPERTY(QUrl url READ url NOTIFY urlChanged)
    Q_PROPERTY(QUrl previewUrl READ previewUrl NOTIFY previewUrlChanged)
    Q_PROPERTY(QString mimeType READ mimeType NOTIFY mimeTypeChanged)
    Q_PROPERTY(int index READ index WRITE setIndex NOTIFY indexChanged)

public:
    explicit ImagitronObject(int index, const QString &url, const QString &previewUrl, const QString &title, QObject *parent = 0);
    QString title() const;
    QUrl url() const;
    QString mimeType() const;
    QUrl previewUrl() const;

    int index() const;

signals:
    void updateUrlsToCached();
    void titleChanged(QString title);
    void urlChanged(QUrl url);
    void mimeTypeChanged(QString mimeType);
    void previewUrlChanged(QUrl previewUrl);

    void indexChanged(int index);

public slots:
    void onObjectCached(QString fileName, bool isPreview = false);
    void downloadFiles();
    void setIndex(int index);

private:
    QString _title;
    QUrl _url;
    QUrl _previewUrl;
    QString _mimeType;
    void setTitle(QString title);
    void setLocatFromRemoteUrl(QUrl url, bool isPreview = false);
    void setUrl(QUrl url);
    void setPreviewUrl(QUrl url);
    void setMimeType(QString mimeType);
    FileDownloader _fd;
    FileDownloader _pfd;
    QString _remoteUrl;
    QString _remotePreviewUrl;
    int _index;
};

#endif // IMAGITRONOBJECT_H
