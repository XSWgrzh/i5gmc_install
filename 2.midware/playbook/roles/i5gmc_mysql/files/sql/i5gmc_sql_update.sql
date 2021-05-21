
use i5gmc;
/*
    2021-01-05
*/
ALTER TABLE `i5gmc`.`i5gmc_enterprise_material`
ADD COLUMN `variable_text` varchar(1024) NULL DEFAULT '' COMMENT '变量json' ;
ALTER TABLE `i5gmc`.`i5gmc_msg_template`
ADD COLUMN `is_composite_picture` tinyint(4) NULL DEFAULT 0  COMMENT '素材是否是合成图';

/**
    2021-01-21
 */
ALTER TABLE `i5gmc`.`i5gmc_robot_config_info`
ADD COLUMN `app_password` varchar(20) NULL COMMENT 'robot登录密码' AFTER `app_secret`;

/**
    2021-3-15 消息回落
 */
ALTER TABLE `i5gmc`.`i5gmc_msg_template`
ADD COLUMN `fallback_type` tinyint(4) NULL DEFAULT 0 COMMENT '回落类型' AFTER `is_composite_picture`,
ADD COLUMN `fallback_content` text CHARACTER SET utf8 NOT NULL COMMENT '回落内容' AFTER `fallback_type`;


ALTER TABLE `i5gmc`.`i5gmc_enterprise_app`
ADD COLUMN `menu_button` text NULL COMMENT '底部按钮' AFTER `flow_limit`;

/**

 */

alter table `i5gmc_enterprise_app` add column  `maap_token` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '身份鉴权时的随机码token';

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for i5gmc_enterprise_material_maap
-- ----------------------------
DROP TABLE IF EXISTS `i5gmc_enterprise_material_maap`;
CREATE TABLE IF NOT EXISTS `i5gmc_enterprise_material_maap`  (
  `id` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `platform_type` tinyint(4) NOT NULL COMMENT '平台类型：\r\n1：电信华东北（上海电信）平台',
  `access_num` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '接入号',
  `local_url` varchar(512) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '本地url',
  `file_name` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '文件名称',
  `file_url` varchar(512) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '文件url',
  `file_size` bigint(20) NOT NULL COMMENT '文件大小',
  `thumbnail_url` varchar(512) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '缩略图url',
  `thumbnail_size` bigint(20) NULL DEFAULT NULL COMMENT '缩略图大小',
  `status` tinyint(4) NOT NULL COMMENT '审核状态 1审核中 2：审核通过3：审核失败',
  `description` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '审核说明',
  `create_time` timestamp(0) NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
  `update_time` timestamp(0) NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '修改时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '存储在Maap平台的媒体' ROW_FORMAT = Compact;

SET FOREIGN_KEY_CHECKS = 1;



/**
  支付路由
 */
insert into i5gmc_sys_function (func_id,func_category,func_name,path,redirect,component,always_show,meta) values (33,2,'支付管理','/pay', '/pay/payChannel','/layout',true,"{ title: '支付管理', icon: 'pay' }");
insert into i5gmc_sys_function (func_id,func_category,func_name,path,pid,name,component,hidden,meta) values (34,2,'支付渠道管理','payChannel', 33,'PayChannel','/pay/PayChannel',true,"{ title: '支付渠道管理', isRouter: '/pay' }");
insert into i5gmc_sys_function (func_id,func_category,func_name,path,pid,name,component,hidden,meta) values (35,2,'支付订单','payOrder', 33,'PayOrder','/pay/PayOrder',true,"{ title: '支付订单', isRouter: '/pay' }");

insert into i5gmc_sys_role_function(role_id,func_id);
select role_id,33 from i5gmc_sys_role where is_admin = 1 and role_category = 2;


/**
    2021-04-09
 */

CREATE TABLE IF NOT EXISTS `i5gmc_pay_channel` (
  `pay_channel_id` varchar(32) NOT NULL COMMENT '支付渠道Id',
  `pay_channel_name` varchar(128) NOT NULL COMMENT '支付渠道名字',
  `pay_channel_desc` varchar(255) NOT NULL DEFAULT '' COMMENT '支付渠道描述',
  `ent_id` int(11) NOT NULL COMMENT '企业id',
  `uid` bigint(20) NOT NULL COMMENT '添加人id',
  `pay_channel_type` int(11) NOT NULL COMMENT '支付渠道类型：1.微信，2支付宝，3银联支付',
  `pay_channel_info` text NOT NULL COMMENT '支付渠道的信息JSON',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `moidfy_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`pay_channel_id`),
  KEY `ent_id` (`ent_id`) USING HASH
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='支付渠道表';

CREATE TABLE IF NOT EXISTS `i5gmc_pay_order` (
  `pay_order_id` varchar(32) NOT NULL COMMENT '支付订单Id',
  `transaction_id` varchar(64) DEFAULT NULL COMMENT '支付平台订单号',
  `out_trade_no` varchar(64) DEFAULT '' COMMENT '商户订单号',
  `ent_id` int(11) NOT NULL COMMENT '企业id',
  `app_id` int(11) NOT NULL COMMENT '应用id',
  `mobile` varchar(20) NOT NULL COMMENT '支付的手机号',
  `pay_channel_type` int(11) DEFAULT NULL COMMENT '支付渠道类型：1.微信，2支付宝，3银联支付',
  `pay_channel_id` varchar(32) DEFAULT NULL COMMENT '支付渠道id',
  `order_desc` varchar(512) NOT NULL COMMENT '订单描述',
  `currency` varchar(32) NOT NULL DEFAULT 'CNY' COMMENT '币种（默认人民币）',
  `amount` int(11) NOT NULL COMMENT '金额 单位分',
  `status` int(11) NOT NULL COMMENT '订单状态，1.取消订单、2.未支付、3支付成功、4退款中、5.退款成功、6.退款失败、7.支付失败',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `pay_time` timestamp NULL DEFAULT NULL COMMENT '支付时间',
  PRIMARY KEY (`pay_order_id`),
  KEY `ent_id` (`ent_id`) USING HASH
) ENGINE=InnoDB DEFAULT CHARSET=utf8;