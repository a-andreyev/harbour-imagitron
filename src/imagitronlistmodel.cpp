#include "imagitronlistmodel.h"
#include <QRegularExpressionMatchIterator>
#include <QStringList>

ImagitronListModel::ImagitronListModel(QObject *parent)
    : QAbstractListModel(parent)
{
    _host = QUrl("http://simonstalenhag.se/");
    _urlPath = "bilderbig/";
    _previewUrlPath = "bilder/";
    _refresh();
}

int ImagitronListModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return _objects.count();
}

QVariant ImagitronListModel::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= _objects.count())
        return QVariant();

    ImagitronObject *object = _objects[index.row()];
    if (role == TitleRole)
        return object->title();
    else if (role == UrlRole)
        return object->url();
    else if (role == PreviewUrlRole)
        return object->previewUrl();
    else if (role == MimeTypeRole)
        return object->mimeType();
    return QVariant();
}

QVariantMap ImagitronListModel::get(int row)
{
    QHash<int,QByteArray> names = roleNames();
    QHashIterator<int, QByteArray> i(names);
    QVariantMap res;
    while (i.hasNext()) {
        i.next();
        QModelIndex idx = index(row, 0);
        QVariant data = idx.data(i.key());
        res[i.value()] = data;
    }
    return res;

}

void ImagitronListModel::refresh()
{
    // TODO: stop refreshing safely and refresh again
    qDebug("TODO: implement");
}

QVariantList ImagitronListModel::getUrlsListForDbus(int row)
{
    QVariantList urlsListForDbus;
    int objCount = _objects.count();
    if (row<objCount) {
        for (int x = row; x<objCount;x++) {
            urlsListForDbus << _objects.at(x)->url().toString();
        }
        for (int x = 0; x<row;x++) {
            urlsListForDbus << _objects.at(x)->url().toString();
        }
    }
    return urlsListForDbus;
}

void ImagitronListModel::_refresh()
{
    // TODO: move to file downloader?
    _response = _manager.get(QNetworkRequest(QUrl(_host)));
    connect(_response, SIGNAL(readyRead()), this, SLOT(_onHostHTMLreadyRead()));
    connect(_response, SIGNAL(error(QNetworkReply::NetworkError)),
            this, SLOT(_onHostHTMLError(QNetworkReply::NetworkError)));
    connect(_response, SIGNAL(sslErrors(QList<QSslError>)),
            this, SLOT(_onHostHTMLSslErrors(QList<QSslError>)));
}

void ImagitronListModel::_clear()
{
    foreach (ImagitronObject* obj, _objects) {
        obj->deleteLater();
    }
    _objects.clear();
}

void ImagitronListModel::_onHostHTMLreadyRead()
{
    // TODO:
    /*
    if (reponse->error() != QNetworkReply::NoError) return;
    QString contentType = response->header(QNetworkRequest::ContentTypeHeader).toString();
    if (!contentType.contains("charset=utf-8")) {
        qWarning() << "Content charsets other than utf-8 are not implemented yet.";
        return;
    }
    */
    QString html = QString::fromUtf8(_response->readAll());
    // HTML looks broken, so hope regexp is my friend
    if (html.length()) {
        if (html!=_hostHTML) {
            _hostHTML = html;
            QRegularExpression re("<a href=\"bilderbig/.*jpg\"");
            QRegularExpressionMatchIterator i = re.globalMatch(_hostHTML);
            QStringList titlesList;
            while (i.hasNext()) {
                QRegularExpressionMatch match = i.next();
                QString newLink = match.captured().split("\"").at(1).split("/").last();
                // fixing simon's typos:
                // by_nestingcliffs_2560 not 1920
                if (newLink=="by_nestingcliffs_1920.jpg") {
                    continue;
                }
                // 2880 not 28800.jpg
                if (newLink.endsWith("28800.jpg")) {
                    continue;
                }
                titlesList.append(newLink);
            }
            titlesList.removeDuplicates();
            // beginInsertRows(QModelIndex(), 0, titlesList.count()-1);
            _clear();
            int counter = 0;
            foreach (QString title, titlesList) {
                QString newLink = title;
                title.replace(QRegExp("_\\d{4}.jpg"),".jpg");
                QString previewLink = title;
                QUrl url = QUrl(_host.toString()+_urlPath+newLink);
                QUrl previewUrl = QUrl(_host.toString()+_previewUrlPath+previewLink);
                if (newLink=="kartan.jpg") {
                    // TODO: sepate to menu
                    //previewUrl = QUrl(); // no preview on website
                    continue;
                }
                ImagitronObject *obj = new ImagitronObject(counter,url.toString(),previewUrl.toString(),title,this);
                connect(obj,SIGNAL(urlChanged(QUrl)),this,SLOT(_handleUrlUpdate(QUrl)));
                connect(obj,SIGNAL(previewUrlChanged(QUrl)),this,SLOT(_handlePreviewUrlUpdate(QUrl)));

                beginInsertRows(QModelIndex(),counter,counter);
                _objects << obj;
                endInsertRows();
                counter++;
            }

            foreach (ImagitronObject* object, _objects) {
                emit object->updateUrlsToCached();
                //return; // TO test first object
            }
            // endInsertRows();
        }
    }
    return;
}

void ImagitronListModel::_onHostHTMLSslErrors(QList<QSslError> sslerr)
{
    qDebug()<< sslerr;
}

void ImagitronListModel::_onHostHTMLError(QNetworkReply::NetworkError err)
{
    qDebug()<< err;
}

void ImagitronListModel::_handleRoleUpdate(int role, int itemIndex)
{
    QModelIndex child = index(itemIndex);
    if(child.isValid()) {
        QVector<int> roles;
        roles.append(role);
        emit dataChanged(child,child,roles);
    }

}

void ImagitronListModel::_handleUrlUpdate(QUrl url)
{
    Q_UNUSED(url); // FIXME
    // TODO: index in signal?
    ImagitronObject* item = static_cast<ImagitronObject*>(sender());
    _handleRoleUpdate(UrlRole,item->index());
}

void ImagitronListModel::_handlePreviewUrlUpdate(QUrl url)
{
    Q_UNUSED(url); // FIXME
    // TODO: index in signal?
    ImagitronObject* item = static_cast<ImagitronObject*>(sender());
    _handleRoleUpdate(PreviewUrlRole,item->index());
}


QHash<int, QByteArray> ImagitronListModel::ImagitronListModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[TitleRole] = "title";
    roles[UrlRole] = "url";
    roles[PreviewUrlRole] = "previewUrl";
    roles[MimeTypeRole] = "mimeType";
    return roles;
}
