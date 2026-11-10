import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { AspectRatio, ProjectMode, ProjectStatus } from 'dramaforge-shared';
import { PrismaService } from '../../prisma.service';

export interface CreateProjectDto {
  title: string;
  mode?: ProjectMode;
  aspectRatio?: AspectRatio;
  stylePreset?: string;
  targetDurationSeconds?: number;
}

@Injectable()
export class ProjectsService {
  constructor(private readonly prisma: PrismaService) {}

  async createProject(userId: string, dto: CreateProjectDto) {
    return this.prisma.project.create({
      data: {
        userId,
        title: dto.title || 'Untitled Short Drama',
        mode: dto.mode ?? ProjectMode.STUDIO,
        aspectRatio: (dto.aspectRatio as any) ?? AspectRatio.PORTRAIT_9_16,
        stylePreset: dto.stylePreset ?? 'cinematic',
        targetDurationSeconds: dto.targetDurationSeconds ?? 30,
        status: ProjectStatus.DRAFT,
      },
    });
  }

  async getUserProjects(userId: string) {
    return this.prisma.project.findMany({
      where: { userId },
      include: {
        stories: {
          include: {
            shots: {
              orderBy: { sequenceIndex: 'asc' },
            },
          },
        },
      },
      orderBy: { updatedAt: 'desc' },
    });
  }

  async getProjectById(userId: string, projectId: string) {
    const project = await this.prisma.project.findUnique({
      where: { id: projectId },
      include: {
        stories: {
          include: {
            shots: {
              orderBy: { sequenceIndex: 'asc' },
            },
          },
        },
      },
    });

    if (!project || project.userId !== userId) {
      throw new NotFoundException('Project not found');
    }

    return project;
  }
}
