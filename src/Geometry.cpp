#include "Geometry.h"

namespace glen
{
    u32 Geometry::getVertexSize() { return vertices.size(); }
    u32 Geometry::getTriangleSize() { return triangles.size(); }

    const vec3 &Geometry::getVertexPosition(const u32 &vertexIndex) const
    {
        assert(vertexIndex < vertices.size());
        return vertices[vertexIndex].position;
    }

    const vec3 &Geometry::getVertexNormal(const u32 &vertexIndex) const
    {
        assert(vertexIndex < vertices.size());
        return vertices[vertexIndex].normal;
    }

    const vec2 &Geometry::getVertexTextCoord(const u32 &vertexIndex) const
    {
        assert(vertexIndex < vertices.size());
        return vertices[vertexIndex].texCoord;
    }

    const uvec3 &Geometry::getTriangleIndices(const u32 &triangleIndex) const
    {
        assert(triangleIndex < triangles.size());
        return triangles[triangleIndex];
    }

    const vec3 &Geometry::getTrianglePoint(const u32 &triangleIndex, const i32 &point) const
    {
        assert(triangleIndex < triangles.size());
        assert(0 < point && point < 3);
        return vertices[ triangles[triangleIndex][point] ].position;
    }

    const f32 *Geometry::getVertexData()
    {
        if(vertices.size() > 0)
            return &vertices[0].position[0];

        return NULL;
    }

    const u32 *Geometry::getTriangleData()
    {
        if(triangles.size() > 0)
            return &triangles[0][0];

        return NULL;
    }

    void Geometry::addVertex(const sVertex &vertex)
    {
        vertices.push_back(vertex);
    }

    void Geometry::addTriangle(const uvec3 &triangle)
    {
        triangles.push_back(triangle);
    }

    const Geometry& Geometry::addGeometry(const Geometry &geom)
    {
        u32 vertexOffset = vertices.size();
        uvec3 tri;

        for(u32 i=0; i<geom.vertices.size(); ++i)
        {
            vertices.push_back(geom.vertices[i]);
        }

        for(u32 i=0; i<geom.triangles.size(); ++i)
        {
            tri = geom.triangles[i];
            tri[0] += vertexOffset;
            tri[1] += vertexOffset;
            tri[2] += vertexOffset;

            triangles.push_back(tri);
        }

        return *this;
    }

    void Geometry::clear()
    {
        vertices.clear();
        triangles.clear();
    }

    void Geometry::calculateNormals()
    {

    }
}
