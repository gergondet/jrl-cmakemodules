# Copyright (C) 2008-2014 LAAS-CNRS, JRL AIST-CNRS.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

#.rst:
# .. command:: _SETUP_PROJECT_DIST
#
#   .. _target-dist:
#
#   Add a *dist* target to generate a tarball using ``git-archive``.
#
#   Linux specific: use ``git-archive-all.sh`` to obtain a recursive
#   ``git-archive`` on the project's submodule.
#   Please note that ``git-archive-all.sh`` is not carefully written
#   and create a temporary file in the source directory
#   (which is then moved to the build directory).
MACRO(_SETUP_PROJECT_DIST)
  IF(UNIX)
    FIND_PROGRAM(TAR tar)
    FIND_PROGRAM(GPG gpg)

    IF(APPLE)
      SET(GIT_ARCHIVE_ALL ${PROJECT_SOURCE_DIR}/cmake/git-archive-all.py)
    ELSE(APPLE)
      SET(GIT_ARCHIVE_ALL ${PROJECT_SOURCE_DIR}/cmake/git-archive-all.sh)
    ENDIF(APPLE)

    # Use git-archive-all.sh to generate distributable source code
    SET(DISTDIR_TARGET "distdir")
    IF(JRL_META_PACKAGE)
      STRING(APPEND DISTDIR_TARGET "-${PROJECT_NAME}")
    ENDIF()
    ADD_CUSTOM_TARGET(${DISTDIR_TARGET}
      COMMAND
      rm -f /tmp/${PROJECT_NAME}.tar
      && ${GIT_ARCHIVE_ALL}
      --prefix ${PROJECT_NAME}${PROJECT_SUFFIX}-${PROJECT_VERSION}/  ${PROJECT_NAME}.tar
      && cd ${CMAKE_BINARY_DIR}/
      && (test -d ${PROJECT_NAME}${PROJECT_SUFFIX}-${PROJECT_VERSION}
    	&& find ${PROJECT_NAME}${PROJECT_SUFFIX}-${PROJECT_VERSION}/ -type d -print0
         | xargs -0 chmod a+w  || true)
      && rm -rf ${PROJECT_NAME}${PROJECT_SUFFIX}-${PROJECT_VERSION}/
      && ${TAR} xf ${PROJECT_SOURCE_DIR}/${PROJECT_NAME}.tar
      && echo "${PROJECT_VERSION}" >
         ${CMAKE_BINARY_DIR}/${PROJECT_NAME}${PROJECT_SUFFIX}-${PROJECT_VERSION}/.version
      && ${PROJECT_SOURCE_DIR}/cmake/gitlog-to-changelog >
      ${CMAKE_BINARY_DIR}/${PROJECT_NAME}${PROJECT_SUFFIX}-${PROJECT_VERSION}/ChangeLog
      && rm -f ${PROJECT_SOURCE_DIR}/${PROJECT_NAME}.tar
      WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
      COMMENT "Generating dist directory..."
      )

    # Create a tar.gz tarball for the project, and generate the signature
    SET(DIST_TARGZ_TARGET "dist_targz")
    IF(JRL_META_PACKAGE)
      STRING(APPEND DIST_TARGZ_TARGET "-${PROJECT_NAME}")
    ENDIF()
    ADD_CUSTOM_TARGET(${DIST_TARGZ_TARGET}
      COMMAND
      ${TAR} -czf ${PROJECT_NAME}${PROJECT_SUFFIX}-${PROJECT_VERSION}.tar.gz
                  ${PROJECT_NAME}${PROJECT_SUFFIX}-${PROJECT_VERSION}/
      && ${GPG} --detach-sign --armor -o
      ${CMAKE_BINARY_DIR}/${PROJECT_NAME}${PROJECT_SUFFIX}-${PROJECT_VERSION}.tar.gz.sig
      ${CMAKE_BINARY_DIR}/${PROJECT_NAME}${PROJECT_SUFFIX}-${PROJECT_VERSION}.tar.gz
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
      COMMENT "Generating tar.gz tarball and its signature..."
      )

    # Create a tar.bz2 tarball for the project, and generate the signature
    SET(DIST_TARBZ2_TARGET "dist_tarbz2")
    IF(JRL_META_PACKAGE)
      STRING(APPEND DIST_TARBZ2_TARGET "-${PROJECT_NAME}")
    ENDIF()
    ADD_CUSTOM_TARGET(${DIST_TARBZ2_TARGET}
      COMMAND
      ${TAR} -cjf ${PROJECT_NAME}${PROJECT_SUFFIX}-${PROJECT_VERSION}.tar.bz2
                  ${PROJECT_NAME}${PROJECT_SUFFIX}-${PROJECT_VERSION}/
      && ${GPG} --detach-sign --armor -o
      ${CMAKE_BINARY_DIR}/${PROJECT_NAME}${PROJECT_SUFFIX}-${PROJECT_VERSION}.tar.bz2.sig
      ${CMAKE_BINARY_DIR}/${PROJECT_NAME}${PROJECT_SUFFIX}-${PROJECT_VERSION}.tar.bz2
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
      COMMENT "Generating tar.bz2 tarball and its signature..."
      )

    # Create a tar.xz tarball for the project, and generate the signature
    SET(DIST_TARXZ_TARGET "dist_tarxz")
    IF(JRL_META_PACKAGE)
      STRING(APPEND DIST_TARXZ_TARGET "-${PROJECT_NAME}")
    ENDIF()
    ADD_CUSTOM_TARGET(${DIST_TARXZ_TARGET}
      COMMAND
      ${TAR} -cJf ${PROJECT_NAME}${PROJECT_SUFFIX}-${PROJECT_VERSION}.tar.xz
                  ${PROJECT_NAME}${PROJECT_SUFFIX}-${PROJECT_VERSION}/
      && ${GPG} --detach-sign --armor -o
      ${CMAKE_BINARY_DIR}/${PROJECT_NAME}${PROJECT_SUFFIX}-${PROJECT_VERSION}.tar.xz.sig
      ${CMAKE_BINARY_DIR}/${PROJECT_NAME}${PROJECT_SUFFIX}-${PROJECT_VERSION}.tar.xz
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
      COMMENT "Generating tar.xz tarball and its signature..."
      )

    # Alias: dist = dist_targz (backward compatibility)
    SET(DIST_TARGET "dist")
    IF(JRL_META_PACKAGE)
      STRING(APPEND DIST_TARGET "-${PROJECT_NAME}")
    ENDIF()
    ADD_CUSTOM_TARGET(${DIST_TARGET} DEPENDS ${DIST_TARGZ_TARGET})

    # TODO: call this during `make clean`
    SET(DISTCLEAN_TARGET "distclean")
    IF(JRL_META_PACKAGE)
      STRING(APPEND DISTCLEAN_TARGET "-${PROJECT_NAME}")
    ENDIF()
    ADD_CUSTOM_TARGET(${DISTCLEAN_TARGET}
      COMMAND
      rm -rf ${CMAKE_BINARY_DIR}/${PROJECT_NAME}${PROJECT_SUFFIX}-${PROJECT_VERSION}/
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
      COMMENT "Cleaning dist sources..."
      )

    SET(DISTORIG_TARGET "distorig")
    IF(JRL_META_PACKAGE)
      STRING(APPEND DISTORIG_TARGET "-${PROJECT_NAME}")
    ENDIF()
    ADD_CUSTOM_TARGET(${DISTORIG_TARGET}
      COMMAND
      cmake -E copy ${PROJECT_NAME}${PROJECT_SUFFIX}-${PROJECT_VERSION}.tar.gz
              ${PROJECT_NAME}${PROJECT_SUFFIX}-${PROJECT_VERSION}.orig.tar.gz
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
      COMMENT "Generating orig tarball..."
      )

    ADD_DEPENDENCIES(${DIST_TARGZ_TARGET} ${DISTDIR_TARGET})
    ADD_DEPENDENCIES(${DIST_TARBZ2_TARGET} ${DISTDIR_TARGET})
    ADD_DEPENDENCIES(${DIST_TARXZ_TARGET} ${DISTDIR_TARGET})
    ADD_DEPENDENCIES(${DISTORIG_TARGET} ${DIST_TARGET})
  ELSE()
    #FIXME: what to do here?
  ENDIF()
ENDMACRO(_SETUP_PROJECT_DIST)
