#ifndef FILEDOWNLOADER_H
#define FILEDOWNLOADER_H

#include <QObject>

#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QFile>

class FileDownloader : public QObject
{
    Q_OBJECT
public:
    explicit FileDownloader(QObject *parent = 0);
    // TODO: destructor
    Q_INVOKABLE void saveFile(const QString &url, const QString &title, bool isPreview = false);

private slots:
    void onReadyRead();
    void onImageChecked(bool isCorrupted);

signals:
    void saveFileSucceeded(const QString &name, bool isPreview);
    void saveFileFailed(const QString &name);
    void imageChecked(bool isCorrupted);

private:
    QUrl _url;
    QNetworkAccessManager _manager;
    QNetworkReply* _reply;
    QFile _imageFile;
    bool _isPreview;
    void _checkFile();
    void _getImage();
};

#endif // FILEDOWNLOADER_H
