import { Body, Controller, Get, Param, Post, Query, SetMetadata, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { UserRole } from 'dramaforge-shared';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { AdjustCoinsDto, AdminService, EnforceUserDto } from './admin.service';

@ApiTags('Admin Panel')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@SetMetadata('roles', [UserRole.ADMIN])
@Controller('admin')
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @Get('users')
  @ApiOperation({ summary: 'Search and list users with wallet balances' })
  async listUsers(@Query('search') search?: string, @Query('limit') limit = 50) {
    return this.adminService.listUsers(search, Number(limit));
  }

  @Post('users/:id/enforce')
  @ApiOperation({ summary: 'Set user enforcement tier (NONE, WARNING, SUSPEND, BAN)' })
  async setEnforcement(@Param('id') id: string, @Body() dto: EnforceUserDto) {
    return this.adminService.setEnforcement(id, dto);
  }

  @Post('users/:id/adjust-coins')
  @ApiOperation({ summary: 'Admin manual coin grant or deduction with audit log' })
  async adjustCoins(@Param('id') id: string, @Body() dto: AdjustCoinsDto) {
    return this.adminService.adjustCoins(id, dto);
  }

  @Get('moderation/queue')
  @ApiOperation({ summary: 'List flagged content moderation events' })
  async getModerationQueue(@Query('limit') limit = 50) {
    return this.adminService.getModerationQueue(Number(limit));
  }

  @Get('providers/health')
  @ApiOperation({ summary: 'Check AI provider health and status' })
  async getProviderHealth() {
    return this.adminService.getProviderHealth();
  }
}
