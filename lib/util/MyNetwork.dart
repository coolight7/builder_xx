// ignore_for_file: non_constant_identifier_names, camel_case_types, constant_identifier_names, unused_import, file_names, unnecessary_this

import 'dart:convert' as convert;
import 'dart:io';
import 'package:dio/dio.dart' as libdio;
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:util_xx/util_xx.dart';
import 'package:refreshed/refreshed.dart';
import 'MySrc.dart';
import 'MyGlobalUtil.dart';

/// mimicry请求状态码
class MyNetStateCode_e {
  static const int Undefined = -1,
      Continue = 1000, // 继续
      ContinueCustom = 1777, // 继续，并附带自定义提示
      OK = 2000, //成功
      OKUseCache = 2304, // 成功，但服务器并不返回内容，请使用缓存
      OKCustom = 2777, // 成功，并附带自定义提示
      JumpCustom = 3777, // 跳转标记，并附带自定义提示
      LoginStateError = 4000, //用户需要登录
      PermissionError = 4001, //权限错误
      ForbiddenError = 4003, //拒绝请求
      NotFoundError = 4004, //请求资源无法找到
      ValueHiatusError = 4010, //参数缺失
      ValueError = 4011, //参数错误
      DeletedError = 4012, //已被删除
      RepearError = 4013, //重复动作
      LockedError = 4014, //已被封禁
      LimitError = 4015, // 违反限制
      Toofast = 4016, // 访问太快
      TooMany = 4017, // 访问次数太多
      VerifyError = 4018, // 验证不通过
      InsufficientCredit = 4019, // 信用评估较低，不可使用
      NotAllowError = 4020, // 不允许的操作
      ExpireError = 4021, // 已过期
      InvalidError = 4022, // 无效
      WaitClientOperate = 4023, // 需要等待客户端进一步操作
      Deprecated = 4024, // 废弃的api，建议更新
      FaildCustom = 4777, // 客户端错误，并附带自定义提示
      FaildTag = 4900,
      Exception = 5000, // 服务器错误
      ExtendException = 5100, // 外部服务器错误
      ExceptionCustom = 5777, // 服务端错误，并附带自定义提示

      NetWorkError = 6001, // 网络状态错误

      DioConnectTimeout = 7001, // 网络连接超时
      DioSendTimeout = 7002, // 请求发生超时
      DioReceiveTimeout = 7003, // 请求接收超时
      /// When the server response, but with a incorrect status, such as 404, 503...
      DioResponse = 7004,

      /// When the request is cancelled, dio will throw a error with this type.
      DioCancel = 7005,

      /// Default error type, Some other Error. In this case, you can
      /// use the DioError.error if it is not null.
      DioOther = 7006;
  static int faildTag(int num) {
    return (FaildTag + num);
  }
}

/// 错误提示信息
class MyErrTipStr_c {
  static final _instance = MyErrTipStr_c(doInit: true);

  static const defUnknownClientError = "未知错误，请更新拟声查看";

  static MyErrTipStr_c to() {
    return MyErrTipStr_c._instance;
  }

  final errTip = <int, String>{};

  MyErrTipStr_c({bool doInit = false}) {
    if (doInit) {
      errTip[MyNetStateCode_e.Undefined] = "未知网络错误";
      errTip[403] = "请求被拒绝";
      errTip[404] = "请求不存在";
      errTip[500] = "服务错误";
      errTip[502] = "服务暂时不可用";
      errTip[503] = "服务正在维护中";
      errTip[MyNetStateCode_e.LoginStateError] = "请登录账号";
      errTip[MyNetStateCode_e.PermissionError] = "权限不足";
      errTip[MyNetStateCode_e.ForbiddenError] = "请求被拒绝";
      errTip[MyNetStateCode_e.NotFoundError] = "请求资源无法找到";
      errTip[MyNetStateCode_e.ValueHiatusError] = "请求参数缺失";
      errTip[MyNetStateCode_e.ValueError] = "请求参数错误";
      errTip[MyNetStateCode_e.DeletedError] = "已被删除";
      errTip[MyNetStateCode_e.RepearError] = "请勿重复操作";
      errTip[MyNetStateCode_e.LockedError] = "已被封禁";
      errTip[MyNetStateCode_e.LimitError] = "违反限制条件";
      errTip[MyNetStateCode_e.Toofast] = "访问太频繁";
      errTip[MyNetStateCode_e.TooMany] = "访问次数太多";
      errTip[MyNetStateCode_e.VerifyError] = "验证失败";
      errTip[MyNetStateCode_e.InsufficientCredit] = "您的信用评估较低，被拒绝";
      errTip[MyNetStateCode_e.NotAllowError] = "不允许该操作";
      errTip[MyNetStateCode_e.ExpireError] = "已过期";
      errTip[MyNetStateCode_e.InvalidError] = "无效操作";
      errTip[MyNetStateCode_e.WaitClientOperate] = "需要等待进一步操作";
      errTip[MyNetStateCode_e.Deprecated] = "该服务已调整，请更新拟声";
      errTip[MyNetStateCode_e.Exception] = "服务器错误，可能正在更新维护";
      errTip[MyNetStateCode_e.ExtendException] = "拟声之外的外部服务错误";
      errTip[MyNetStateCode_e.NetWorkError] = "网络状态错误";
      errTip[MyNetStateCode_e.DioConnectTimeout] = "网络连接超时";
      errTip[MyNetStateCode_e.DioSendTimeout] = "网络请求超时";
      errTip[MyNetStateCode_e.DioReceiveTimeout] = "网络接收超时";
      // errTip[MyNetStateCode_e.DioCancel] = "请求取消";
      // errTip[MyNetStateCode_e.DioOther] = "未知网络错误";
    }
  }

  void addAll(Map<int, String> map) {
    errTip.addAll(map);
  }

  String? get(int in_num) {
    return errTip[in_num];
  }

  String? getCustomTip(int in_num, String? respTip) {
    switch (in_num) {
      case MyNetStateCode_e.ContinueCustom:
      case MyNetStateCode_e.OKCustom:
      case MyNetStateCode_e.FaildCustom:
      case MyNetStateCode_e.ExceptionCustom:
        return respTip;
      default:
        return null;
    }
  }

  String? tryGet(int in_num, String respTip) {
    final reStr = get(in_num) ?? getCustomTip(in_num, respTip);
    if (null == reStr) {
      if (respTip.isNotEmpty) {
        return respTip;
      }
      return errTip[MyNetStateCode_e.Undefined];
    }
    return reStr;
  }

  /// *  当in_num对应的tip不存在时
  /// *  尝试获取自定义提示
  /// *  否则使用undefined填充，
  /// *  若undefined对应的tip也不存在，则返回空字符串
  String mustGet(int in_num, String respTip) {
    var result = tryGet(in_num, respTip);
    if (null == result && in_num / 1000 > 0) {
      // 自定义的状态码
      return defUnknownClientError;
    }
    return result ?? "";
  }
}

/// mimicry响应体
class MyResponse_c {
  int code;
  dynamic data;
  String tip;

  MyResponse_c({
    this.code = MyNetStateCode_e.OK,
    this.data = "",
    this.tip = "",
  });

  MyResponse_c.faild()
      : code = MyNetStateCode_e.Undefined,
        data = "",
        tip = "";

  static MyResponse_c? fromJson(Map<String, dynamic> json) {
    try {
      return MyResponse_c(
        code: json["code"] ?? MyNetStateCode_e.Undefined,
        data: json["data"] ?? {},
        tip: json["tip"] ?? "",
      );
    } catch (e) {
      return null;
    }
  }

  static MyResponse_c? fromJsonStr(
    String json, {
    String? appendErrorLog,
  }) {
    try {
      final data = convert.jsonDecode(json);
      if (data is! Map) {
        return null;
      }
      return MyResponse_c.fromJson(data as dynamic);
    } catch (e) {
      // 解析错误
      MyNetClient_c.mylog.severe(LogxxItem(
        prefix: "Json解析错误",
        msg: [
          e.toString(),
          if (null != appendErrorLog) appendErrorLog,
          json,
        ],
      ));
      return null;
    }
  }

  static MyResponse_c fromResp(libdio.Response<dynamic>? resp) {
    try {
      if (null != resp) {
        if (null != resp.extra[MyNetClient_c.extraNAME_myRespCache]) {
          return resp.extra[MyNetClient_c.extraNAME_myRespCache];
        } else {
          MyResponse_c? myResp;

          if ((resp.statusCode ?? 0) / 100 == 2) {
            if (resp.data is String) {
              myResp = MyResponse_c.fromJsonStr(
                resp.data,
                appendErrorLog: resp.statusCode?.toString(),
              );
            } else if (resp.data is Map) {
              myResp = MyResponse_c.fromJson(resp.data);
            }
          }

          myResp ??= MyResponse_c.faild();
          resp.extra[MyNetClient_c.extraNAME_myRespCache] = myResp;
          return myResp;
        }
      }
    } catch (e) {
      // 解析错误
      MyNetClient_c.mylog.severe(LogxxItem(
        prefix: "resp 解析错误",
        msg: [
          e.toString(),
        ],
      ));
    }

    return MyResponse_c.faild();
  }

  bool isSuccessCode() {
    return (MyNetStateCode_e.OK == code ||
        MyNetStateCode_e.OKUseCache == code ||
        MyNetStateCode_e.OKCustom == code);
  }

  bool isSuccessUseCache() {
    return MyNetStateCode_e.OKUseCache == code;
  }

  /// 检查请求是否成功
  bool isSuccess({
    bool checkDataNotNull = false, // 检查data是否不为null
    bool checkDataNotEmpty = false, // 检查data是否不为null且不为空
  }) {
    try {
      return ((MyNetStateCode_e.OK == code ||
              MyNetStateCode_e.OKCustom == code) &&
          // 只要 [checkDataNotNull] 和 [checkDataNotEmpty] 有一个为 true，则需要检查 null != data
          ((false == checkDataNotEmpty && false == checkDataNotNull) ||
              null != data) &&
          (false == checkDataNotEmpty ||
              data is int ||
              data is double ||
              data.isNotEmpty));
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    }
  }

  /// 检查请求失败是否是因为外部原因。
  /// * 即响应在http状态码的失败
  /// * 而非http状态码 == 200，然后在data.code指定错误的类型
  bool isFaild_external() {
    return (MyNetStateCode_e.Undefined == code);
  }

  Map<String, dynamic> toJson() {
    return {
      "code": code,
      if (null != data) "data": data,
      "tip": tip,
    };
  }

  String toJsonStr() {
    return convert.jsonEncode(toJson());
  }

  @override
  String toString() {
    return "$code; ${data.toString()}; $tip";
  }
}

class MyNetHeaderName_e {
  static const String Host = "Host",
      Referer = "Referer",
      Origin = "Origin",
      UserAgent = "User-Agent",
      Cookie = "Cookie",
      ApiVersion = "ApiVersion",
      AcceptLanguage = "Accept-Language",
      Authorization = "Authorization";

  static const String Cos_md5 = "x-cos-meta-md5";
  static const String JWTName_user = "JwtUser"; // jwt_user请求头名称
  static const String JWTNAME_accessToken = "AccessToken";
  static const String JWTNAME_reflushToken = "ReflushToken";
  static const String ClientInfo = "ClientInfo"; // app信息
}

/// 网络请求控制管理
class MyNetClient_c {
  static final mylog = Loggerxx(className: "MyNet_c");
  static const connectTimeout = Duration(seconds: 8),
      receiveTimeout = Duration(seconds: 16), // 接收超时
      sendTimeout = Duration(seconds: 16); // 发送超时

  static final myDioOptions = libdio.BaseOptions(
        connectTimeout: connectTimeout, // 连接超时
        receiveTimeout: receiveTimeout, // 接收超时
        sendTimeout: sendTimeout, // 发送超时
        maxRedirects: 3,
        followRedirects: true,
      ),
      dioOptions = libdio.BaseOptions(
        connectTimeout: connectTimeout, // 连接超时
        receiveTimeout: const Duration(seconds: 60), // 接收超时
        sendTimeout: sendTimeout, // 发送超时
        maxRedirects: 3,
        followRedirects: true,
      );
  static const String extraNAME_isTip = "istip",
      extraNAME_flushJwt = "flushJwt",
      extraNAME_writeErrorLog = "writeErrorLog",
      extraNAME_myRespCache = "myRespCache",
      extraNAME_myErrTipObj = "myErrTipObj";

  //  外部请求使用的ua
  static const defExtendsUserAgentStr =
      "Mozilla/5.0 (Linux; Android 14; arm64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.6045.160 Mobile Safari/537.36 Musicxx/77";

  final libdio.Dio myDio, dio;

  late String def_apiVersion;
  String jwtUser = ""; // jwt_user令牌
  final String def_langs;
  final String def_myApi_prefix;
  final String? def_myApi_referer;
  final String? def_myApi_origin;
  final String? def_myApi_host;
  final String? def_myApi_userAgant;
  final String? def_myApi_clientInfo;

  MyNetClient_c({
    required this.def_myApi_prefix,
    required this.def_langs,
    required int apiVersion,
    this.def_myApi_referer,
    this.def_myApi_origin,
    this.def_myApi_host,
    this.def_myApi_userAgant,
    this.def_myApi_clientInfo,
  })  : myDio = libdio.Dio(myDioOptions),
        dio = libdio.Dio(dioOptions) {
    def_apiVersion = apiVersion.toString();
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client =
            HttpClient(context: SecurityContext(withTrustedRoots: false));
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return true;
        };
        return client;
      },
    );
    // 获取错误提示
    String getErrTip(int in_num, String respTip, dynamic errTipObj) {
      String? tip;
      if (errTipObj is MyErrTipStr_c) {
        // 存在自定义提示
        tip = errTipObj.tryGet(in_num, respTip);
      }
      // 兜底默认提示
      tip ??= MyErrTipStr_c.to().mustGet(in_num, respTip);
      return tip;
    }

    void onErrorDo(
      libdio.DioException e,
      libdio.ErrorInterceptorHandler handler,
    ) {
      if (false !=
          e.requestOptions.extra[MyNetClient_c.extraNAME_writeErrorLog]) {
        // 如果没有禁用写入日志
        switch (e.type) {
          case libdio.DioExceptionType.cancel:
            break;
          default:
            mylog.severe(LogxxItem(
              prefix: "网络请求错误",
              msg: [
                e.toString(),
                (convert.jsonEncode({
                  "headers": e.requestOptions.headers.toString(),
                  "uri": e.requestOptions.path,
                }))
              ],
            ));
        }
      }
      if (true == e.requestOptions.extra[MyNetClient_c.extraNAME_isTip]) {
        // 是否显示错误提示
        String? tip;
        switch (e.type) {
          case libdio.DioExceptionType.connectionTimeout:
            tip = getErrTip(MyNetStateCode_e.DioConnectTimeout, "",
                e.requestOptions.extra[MyNetClient_c.extraNAME_myErrTipObj]);
            break;
          case libdio.DioExceptionType.sendTimeout:
            tip = getErrTip(MyNetStateCode_e.DioSendTimeout, "",
                e.requestOptions.extra[MyNetClient_c.extraNAME_myErrTipObj]);
            break;
          case libdio.DioExceptionType.receiveTimeout:
            tip = getErrTip(MyNetStateCode_e.DioReceiveTimeout, "",
                e.requestOptions.extra[MyNetClient_c.extraNAME_myErrTipObj]);
            break;
          case libdio.DioExceptionType.badResponse:
            tip = getErrTip(
                e.response?.statusCode ?? MyNetStateCode_e.DioResponse,
                "",
                e.requestOptions.extra[MyNetClient_c.extraNAME_myErrTipObj]);
            break;
          case libdio.DioExceptionType.connectionError:
          case libdio.DioExceptionType.badCertificate: // 证书问题
          case libdio.DioExceptionType.unknown: // 未知问题
            tip = getErrTip(
              MyNetStateCode_e.Undefined,
              "",
              e.requestOptions.extra[MyNetClient_c.extraNAME_myErrTipObj],
            );
            break;
          case libdio.DioExceptionType.cancel: // 取消请求
            tip = "请求取消";
        }
        showTip(tip);
      }
      final resp = e.response;
      if (null == resp) {
        handler.next(e);
      } else {
        handler.resolve(resp); //continue
      }
    }

    // myDio.httpClientAdapter = NativeAdapter();
    myDio.interceptors.add(libdio.InterceptorsWrapper(
      onRequest: (options, handler) {
        // 添加jwt
        options.headers[MyNetHeaderName_e.JWTNAME_accessToken] = jwtUser;
        // 添加 客户端信息
        options.headers[MyNetHeaderName_e.ApiVersion] = def_apiVersion;
        options.headers[MyNetHeaderName_e.AcceptLanguage] = def_langs;
        if (null != def_myApi_userAgant) {
          options.headers[MyNetHeaderName_e.UserAgent] = def_myApi_userAgant;
        }
        if (null != def_myApi_clientInfo) {
          options.headers[MyNetHeaderName_e.ClientInfo] = def_myApi_clientInfo;
        }
        return handler.next(options); //continue
      },
      onResponse: ((resp, handler) async {
        Object? error;
        final myResp = MyResponse_c.fromResp(resp);
        if (false == myResp.isSuccessCode()) {
          // 请求失败
          if (MyNetStateCode_e.LoginStateError == myResp.code &&
              true ==
                  resp.requestOptions.extra[MyNetClient_c.extraNAME_flushJwt]) {
            // 错误原因为登录状态失效，且允许刷新重试
            final flush = await flushSignIn(doTip: false);
            if (flush) {
              // 刷新登录状态成功
              try {
                final req = resp.requestOptions;
                final result = await myDio.request(
                  req.path,
                  data: req.data,
                  queryParameters: req.queryParameters,
                  cancelToken: req.cancelToken,
                  options: libdio.Options(
                    method: req.method,
                    sendTimeout: req.sendTimeout,
                    receiveTimeout: req.receiveTimeout,
                    extra: req.extra,
                    headers: req.headers,
                    responseType: req.responseType,
                    contentType: req.contentType,
                    validateStatus: req.validateStatus,
                    receiveDataWhenStatusError: req.receiveDataWhenStatusError,
                    followRedirects: req.followRedirects,
                    maxRedirects: req.maxRedirects,
                    requestEncoder: req.requestEncoder,
                    responseDecoder: req.responseDecoder,
                    listFormat: req.listFormat,
                  ),
                  onSendProgress: req.onSendProgress,
                  onReceiveProgress: req.onReceiveProgress,
                );
                return handler.resolve(result);
              } catch (e) {
                error = e;
              }
            }
          }
          if (true ==
              resp.requestOptions.extra[MyNetClient_c.extraNAME_isTip]) {
            //显示错误提示
            final tip = getErrTip(
              myResp.code,
              myResp.tip,
              resp.requestOptions.extra[MyNetClient_c.extraNAME_myErrTipObj],
            );
            // 错误提示
            showTip(tip);
          }
          mylog.severe(LogxxItem(
            prefix: "服务请求失败",
            msg: [
              myResp.toString(),
              if (null != error) error.toString(),
              (convert.jsonEncode({
                "headers": resp.headers.toString(),
                "uri": resp.realUri.toString(),
              }))
            ],
          ));
        }
        return handler.next(resp); // continue
      }),
      onError: onErrorDo,
    ));
    // dio.httpClientAdapter = NativeAdapter();
    dio.interceptors.add(libdio.InterceptorsWrapper(
      onRequest: (options, handler) {
        // 添加默认ua
        options.headers[MyNetHeaderName_e.UserAgent] ??= defExtendsUserAgentStr;
        return handler.next(options); //continue
      },
      onError: onErrorDo,
    ));
  }

  static String listToUrlParams(String name, List<int> list) {
    // 合成url
    String url = "$name=${list[0]}";
    for (int i = 1, len = list.length; i < len; ++i) {
      url = "$url&$name=${list[i]}";
    }
    return url;
  }

  static String headerToMPVString(Map<String, String> headers) {
    String restr = "";
    headers.forEach((key, value) {
      if (restr.isNotEmpty) {
        restr += ",";
      }
      restr += "$key: $value";
    });
    return restr;
  }

  void showTip(String str) {}

  Future<bool> flushSignIn({bool doTip = true}) async {
    return false;
  }

  Future<libdio.Response<T>?> myPost<T>(
    String in_url, {
    MyErrTipStr_c? errTipObj,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? header,
    String? prefix,
    libdio.CancelToken? cancelToken,
    bool? writeErrorLog,
    bool doErrTip = true, // 是否在错误时自动弹出提示
    bool doFlushJwt = true, // 是否在登录状态失效时尝试刷新jwt
    String contentType = "application/x-www-form-urlencoded",
  }) async {
    // * 注意不要在传入的[header]上修改，可能导致加入的请求头传递出去，并影响[header]
    // 复用传给其他请求
    final useHeader = <String, dynamic>{
      MyNetHeaderName_e.Referer: def_myApi_referer,
      MyNetHeaderName_e.Origin: def_myApi_origin,
      MyNetHeaderName_e.Host: def_myApi_host,
    };
    if (null != header) {
      useHeader.addAll(header);
    }
    try {
      // 自动补齐url
      String url = in_url;
      if (null != prefix) {
        url = prefix + url;
      } else if (url.startsWith(RegExp(r"[/.]"))) {
        url = def_myApi_prefix + in_url;
      }
      final resp = await myDio.post<T>(
        url,
        queryParameters: queryParameters,
        data: data,
        cancelToken: cancelToken,
        options: libdio.Options(
          headers: useHeader,
          extra: {
            MyNetClient_c.extraNAME_writeErrorLog: writeErrorLog,
            MyNetClient_c.extraNAME_isTip: doErrTip,
            MyNetClient_c.extraNAME_flushJwt: doFlushJwt,
            MyNetClient_c.extraNAME_myErrTipObj: errTipObj,
          },
          contentType: contentType,
        ),
      );
      return resp;
    } catch (e) {
      return null;
    }
  }

  Future<libdio.Response<T>?> myPost_json<T>(
    String in_url, {
    MyErrTipStr_c? errTipObj,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? header,
    String? prefix,
    libdio.CancelToken? cancelToken,
    bool? writeErrorLog,
    bool doErrTip = true,
  }) {
    return myPost<T>(
      in_url,
      contentType: "application/json",
      errTipObj: errTipObj,
      data: data,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      header: header,
      prefix: prefix,
      writeErrorLog: writeErrorLog,
      doErrTip: doErrTip,
    );
  }

  Future<libdio.Response<T>?> myPost_binary<T>(
    String in_url, {
    MyErrTipStr_c? errTipObj,
    String? contentType,
    List<int>? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? header,
    String? prefix,
    libdio.CancelToken? cancelToken,
    bool? writeErrorLog,
    bool doErrTip = true, // 是否在错误时自动弹出提示
  }) {
    return myPost(
      in_url,
      errTipObj: errTipObj,
      contentType: contentType ?? "application/octet-stream",
      queryParameters: queryParameters,
      data: (null != data) ? Stream.fromIterable(data.map((e) => [e])) : null,
      header: header,
      cancelToken: cancelToken,
      prefix: prefix,
      writeErrorLog: writeErrorLog,
      doErrTip: doErrTip,
    );
  }

  Future<libdio.Response<T>?> myGet<T>(
    String in_url, {
    MyErrTipStr_c? errTipObj,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? header,
    String? prefix,
    libdio.ResponseType? responseType,
    libdio.CancelToken? cancelToken,
    void Function(int count, int total)? onReceiveProgress,
    bool doErrTip = true, // 是否在错误时自动弹出提示
    bool doFlushJwt = true, // 是否在登录状态失效时尝试刷新jwt
    bool? writeErrorLog,
  }) async {
    // * 注意不要在传入的[header]上修改，可能导致加入的请求头传递出去，并影响[header]
    // 复用传给其他请求
    final useHeader = <String, dynamic>{
      MyNetHeaderName_e.Referer: def_myApi_referer,
      MyNetHeaderName_e.Origin: def_myApi_origin,
      MyNetHeaderName_e.Host: def_myApi_host,
    };
    if (null != header) {
      useHeader.addAll(header);
    }
    try {
      // 自动补齐url
      String url = in_url;
      if (null != prefix) {
        url = prefix + url;
      } else if (url.startsWith(RegExp(r"[/.]"))) {
        url = def_myApi_prefix + in_url;
      }
      final resp = await myDio.get<T>(
        url,
        queryParameters: queryParameters,
        options: libdio.Options(
          headers: useHeader,
          responseType: responseType,
          extra: {
            MyNetClient_c.extraNAME_writeErrorLog: writeErrorLog,
            MyNetClient_c.extraNAME_isTip: doErrTip,
            MyNetClient_c.extraNAME_flushJwt: doFlushJwt,
            MyNetClient_c.extraNAME_myErrTipObj: errTipObj,
          },
        ),
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return resp;
    } catch (e) {
      return null;
    }
  }

  Future<libdio.Response<T>?> post<T>(
    String in_url, {
    dynamic data,
    String? contentType,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? header,
    bool doErrTip = true, // 是否在错误时自动弹出提示
    libdio.CancelToken? cancelToken,
    bool? writeErrorLog,
  }) async {
    try {
      final resp = await dio.post<T>(
        in_url,
        queryParameters: queryParameters,
        data: data,
        cancelToken: cancelToken,
        options: libdio.Options(
          headers: header,
          extra: {
            MyNetClient_c.extraNAME_writeErrorLog: writeErrorLog,
            MyNetClient_c.extraNAME_isTip: doErrTip,
          },
          contentType: contentType ?? "application/x-www-form-urlencoded",
        ),
      );
      return resp;
    } catch (e) {
      return null;
    }
  }

  Future<libdio.Response<dynamic>?> download<T>(
    String in_url,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? header,
    libdio.ResponseType? responseType,
    libdio.CancelToken? cancelToken,
    void Function(int count, int total)? onReceiveProgress,
    bool doErrTip = true, // 是否在错误时自动弹出提示
    bool? writeErrorLog,
  }) async {
    try {
      final resp = await dio.download(
        in_url,
        savePath,
        queryParameters: queryParameters,
        options: libdio.Options(
          responseType: responseType,
          headers: header,
          extra: {
            MyNetClient_c.extraNAME_writeErrorLog: writeErrorLog,
            MyNetClient_c.extraNAME_isTip: doErrTip,
          },
        ),
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return resp;
    } catch (e) {
      return null;
    }
  }

  Future<libdio.Response<T>?> get<T>(
    String in_url, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? header,
    libdio.ResponseType? responseType,
    libdio.CancelToken? cancelToken,
    void Function(int count, int total)? onReceiveProgress,
    bool doErrTip = true, // 是否在错误时自动弹出提示
    bool? writeErrorLog,
  }) async {
    try {
      final resp = await dio.get<T>(
        in_url,
        queryParameters: queryParameters,
        options: libdio.Options(
          responseType: responseType,
          headers: header,
          extra: {
            MyNetClient_c.extraNAME_writeErrorLog: writeErrorLog,
            MyNetClient_c.extraNAME_isTip: doErrTip,
          },
        ),
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return resp;
    } catch (e) {
      return null;
    }
  }

  Future<libdio.Response<T>?> put<T>(
    String in_url, {
    dynamic data,
    String? contentType = "application/octet-stream",
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? header,
    libdio.CancelToken? cancelToken,
    void Function(int count, int total)? onSendProgress,
    Duration? sendTimeout,
    bool doErrTip = true, // 是否在错误时自动弹出提示
    bool? writeErrorLog,
  }) async {
    try {
      final resp = await dio.put<T>(
        in_url,
        queryParameters: queryParameters,
        data: data,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
        options: libdio.Options(
          headers: header,
          extra: {
            MyNetClient_c.extraNAME_isTip: doErrTip,
            MyNetClient_c.extraNAME_writeErrorLog: writeErrorLog,
          },
          contentType: contentType,
          sendTimeout: sendTimeout ?? const Duration(seconds: 60),
        ),
      );
      return resp;
    } catch (e) {
      return null;
    }
  }

  /// 处理 http/Get 重定向
  Future<String?> handleHttpRedirect(
    String url, {
    Map<String, dynamic>? header,
    int limit = 3,
  }) async {
    try {
      final resp = await dio.head(
        url,
        options: libdio.Options(
          maxRedirects: limit,
          followRedirects: true,
          headers: header,
        ),
      );
      return resp.realUri.toString();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  /// 截取Url链接的 Host 部分
  static String? getUrlHost(String in_url) {
    for (int i = 0, len = in_url.length; i < len; ++i) {
      //寻找 //
      if ((in_url[i] == '/' || in_url[i] == '\\') &&
          i + 1 < len &&
          (in_url[i + 1] == '/' || in_url[i + 1] == '\\')) {
        i += 2;
        int rindex = i;
        for (; rindex < len; ++rindex) {
          //寻找 / 或 结束\0
          if (in_url[rindex] == '/' || in_url[rindex] == '\\') {
            break;
          }
        }
        return in_url.substring(i, rindex);
      }
    }
    return null;
  }

  static String? getUrlOrigin(String in_url) {
    for (int lindex = 0, len = in_url.length; lindex < len; ++lindex) {
      //寻找 //
      if (in_url[lindex] == '/' && in_url[(lindex + 1)] == '/') {
        lindex += 2;
        int rindex = lindex;
        for (; rindex < len; ++rindex) {
          //寻找 / 或 结束\0
          if (in_url[rindex] == '/') {
            break;
          }
        }
        return in_url.substring(0, rindex);
      }
    }
    return null;
  }

  static String urlLtrim(String str, [String? chars]) {
    var pattern = chars != null ? RegExp('^[$chars]+') : RegExp(r'^\s+');
    return str.replaceAll(pattern, '');
  }

  static String urlRtrim(String str, [String? chars]) {
    var pattern = chars != null ? RegExp('[$chars]+\$') : RegExp(r'\s+$');
    return str.replaceAll(pattern, '');
  }

  static String urlJoinPath(String path0, String path1) {
    return '${urlRtrim(path0, '/')}/${urlLtrim(path1, '/')}';
  }
}
