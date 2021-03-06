# -*- coding: utf-8 -*-

def Rgraphum::Vertices(array)
  if array.instance_of?(Rgraphum::Vertices)
    array
  else
    Rgraphum::Vertices.new(array)
  end
end

class Rgraphum::Vertices < Rgraphum::RgraphumArray
  include Rgraphum::RgraphumArrayDividers

  # Non-Gremlin methods

  def initialize(vertex_hashes=[])
    super()
    @id_vertex_map = {}
    vertex_hashes.each do |vertex_hash|
      self << vertex_hash
    end
  end

  def find_by_id(vertex_id)
    if vertex_id.is_a?(Rgraphum::Vertex)
      id = vertex_id.id
    else
      id = vertex_id
    end
    @id_vertex_map[id]
  end

  # FIXME use initialize_copy instead
  def dup
    edges = map{ |vertex| vertex.edges }.flatten.uniq
    vertices = super
    vertices.each {|vertex| vertex.edges = Rgraphum::Edges.new }

    edges.each do |edge_source|
      edge = edge_source.dup
      edge.source = vertices.find_by_id(edge.source.id)
      edge.target = vertices.find_by_id(edge.target.id)

      edge.source.edges << edge
      edge.target.edges << edge
    end

    vertices
  end

  def build(vertex_hash)
    vertex = Rgraphum::Vertex(vertex_hash)
    vertex.graph = @graph
    vertex.id = new_id(vertex.id)
    original_push_1(vertex)
    @id_vertex_map[vertex.id] = vertex
    vertex
  end

  alias :original_push_1 :<<
  def <<(vertex_hash)
    build(vertex_hash)
    self
  end

  alias :original_push_m :push
  def push(*vertex_hashs)
    vertex_hashs.each do |vertex_hash|
      build(vertex_hash)
    end
    self
  end

  # Called from delete_if, reject! and reject
  def delete(vertex_or_id)
    id = vertex_or_id.id rescue vertex_or_id
    target_vertex = find_by_id(id)
    unless target_vertex.edges.empty?
      target_vertex.edges.reverse_each do |edge|
        target_vertex.edges.delete(edge)
      end
    end
    @id_vertex_map.delete id
    super(target_vertex)
  end

  def to_community
    Rgraphum::Community.new(vertices: self)
  end

  def to_graph
    to_community.to_graph
  end

  protected :original_push_1
  protected :original_push_m
end
