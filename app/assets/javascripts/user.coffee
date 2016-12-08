# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

currentUser = null   # 当前用户

$ ->
  $('body').hide()  # 隐藏body，等待钉钉那边信息获取结束之后再显示
  startInitDingtalk()
  return

# 开始钉钉的初始化
startInitDingtalk = () ->
  queryDingtalkConfig(
    (config) -> initDingtalk(config),
    () -> dd.device.notification.alert({
      title: "访问天梯服务器失败",
      message: "点击确定返回上一页",
      onSuccess: () -> dd.biz.navigation.close()
    }))
  return

# 初始化钉钉
initDingtalk = (config) ->
  config.agentId = agentId
  config.jsApiList = ['biz.user.get']
  dd.config(config)
  dd.ready(() ->
    queryCurrentUserInfo()
  )
  dd.error((err) ->
    dd.device.notification.alert({
      title: "访问钉钉服务器失败",
      message: "点击确定返回上一页",
      onSuccess: () -> dd.biz.navigation.close()
    }))
  return

# 向自己的服务器请求相关的钉钉配置信息
queryDingtalkConfig = (successfulCallback, failedCallback) ->
  $.ajax '/admin/jsapiconfig',
    type: 'POST'
    data: {url: $.base64.encode(window.location.href)}
    error: (jqXHR, textStatus, errorThrown) ->
      failedCallback() if failedCallback
    success: (data, textStatus, jqXHR) ->
      successfulCallback(data.config) if successfulCallback
  return

# 向钉钉服务器当前用户信息
queryCurrentUserInfo = () ->
  dd.biz.user.get({
    onSuccess: (info) ->
      currentUser = new User(info)
      $('body').show()
    onFail: (err) -> dd.device.notification.alert({
      title: "访问钉钉服务器失败",
      message: "点击确定返回上一页",
      onSuccess: () -> dd.biz.navigation.close()
    })
  })
  return

# 用户
class User
  constructor: (data) ->
    @dingtalkId = data.emplId

  getDingtalkId: () ->
    return @dingtalkId

$ ->
  $('#test').click(->
#    dd.device.notification.toast({
#      text: 'just s test'
#    });
    dd.biz.user.get({
      onSuccess: (info) -> console.log(info),
      onFail: (err) -> dd.device.notification.alert({
        title: "访问钉钉服务器失败",
        message: "点击确定返回上一页",
        onSuccess: () -> dd.biz.navigation.close()
      })
    })
#    dd.biz.navigation.close()
  )
  return