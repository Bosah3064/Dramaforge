import { Body, Controller, Get, Param, Post, Req, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CreateProjectDto, ProjectsService } from './projects.service';

@ApiTags('Projects')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('projects')
export class ProjectsController {
  constructor(private readonly projectsService: ProjectsService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new Short Drama project' })
  @ApiResponse({ status: 201, description: 'Project created' })
  async createProject(@Req() req: any, @Body() dto: CreateProjectDto) {
    return this.projectsService.createProject(req.user.id, dto);
  }

  @Get()
  @ApiOperation({ summary: 'List user projects' })
  async getUserProjects(@Req() req: any) {
    return this.projectsService.getUserProjects(req.user.id);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get single project with stories and shots' })
  async getProjectById(@Req() req: any, @Param('id') id: string) {
    return this.projectsService.getProjectById(req.user.id, id);
  }
}
