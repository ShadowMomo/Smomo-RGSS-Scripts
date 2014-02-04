#==============================================================================
# ■ 保存地图状态
#  作者：影月千秋
#  版本：V 1.0
#  最近更新：2014.01.22
#  适用：VA
#------------------------------------------------------------------------------
# ● 简介
#  在离开一个地图的时候，保存它的状态，包括事件、载具的各属性（位置等）
#==============================================================================
# ● 使用方法
#   将此脚本插入到其他脚本以下，Main以上
#   下方可以设定不保存状态的特殊地图
#==============================================================================
# ● 更新
#   V 1.1 2014.02.04 增强兼容性
#   V 1.0 2014.01.22 新建
#==============================================================================
# ● 声明
#   本脚本来自【影月千秋】，使用、修改和转载请保留此信息
#==============================================================================
module Smomo
  module SaveMapStatus
    NoSave = [1]
    # 在哪些地图不保存状态
#=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+#
#------------------------------------------------------------------------------#
#                               请勿跨过这块区域                                #
#------------------------------------------------------------------------------#
#+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=#
  end
end
class Game_Map
  attr_accessor :mo_save_map_status
  alias :mo_save_status_setup :setup
  def setup(map_id)
    @mo_save_map_status ||= {}
    @mo_save_map_status[@map_id] ||= {}
    no_save_list = [:@screen, :@interpreter, :@display_x, :@display_y,
    :@parallax_name, :@battleback1_name, :@battleback2_name, :@name_display,
    :@need_refresh]
    instance_variables.each do |s|
      next if no_save_list.include?(s) ||
      Smomo::SaveMapStatus::NoSave.include?(@map_id)
      @mo_save_map_status[@map_id][s] = instance_variable_get(s).clone rescue
      instance_variable_get(s)
    end
    mo_save_status_setup(map_id)
    @mo_save_map_status[@map_id] ||= {}
    instance_variables.each do |s|
      next if no_save_list.include?(s) ||
      Smomo::SaveMapStatus::NoSave.include?(@map_id)
      instance_variable_set(s, @mo_save_map_status[@map_id][s]) unless
      @mo_save_map_status[@map_id][s].nil?
    end
  end
end
#==============================================================================#
#=====                        =================================================#
           "■ 脚 本 尾"
#=====                        =================================================#
#==============================================================================#
