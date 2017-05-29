#ifndef IMAGITRONLISTMODEL_H
#define IMAGITRONLISTMODEL_H

#include <QObject>
#include <QAbstractListModel>
#include <QUrl>
#include <QVariantList>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include "imagitronobject.h"

class ImagitronListModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum ImagitronRoles {
        TitleRole = Qt::UserRole + 1,
        UrlRole,
        PreviewUrlRole,
        MimeTypeRole
    };

    ImagitronListModel(QObject *parent = 0);

    int rowCount(const QModelIndex & parent = QModelIndex()) const;

    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const;

    Q_INVOKABLE QVariantMap get(int row);
    Q_INVOKABLE void refresh();
    Q_INVOKABLE QVariantList getUrlsListForDbus(int row);

    QHash<int, QByteArray> roleNames() const;
signals:
    void hostHTMLchanged();
public slots:
    void _onHostHTMLreadyRead();
    void _onHostHTMLSslErrors(QList<QSslError> sslerr);
    void _onHostHTMLError(QNetworkReply::NetworkError err);

    void _handleUrlUpdate(QUrl url);
    void _handlePreviewUrlUpdate(QUrl url);
    void _handleRoleUpdate(int role, int itemIndex);

private:
    QList<ImagitronObject*> _objects;
    void _refresh();
    void _clear();
    QNetworkAccessManager _manager;
    QNetworkReply *_response;
    QUrl _host;
    QString _urlPath;
    QString _previewUrlPath;
    QString _hostHTML;
};

#endif // IMAGITRONLISTMODEL_H
